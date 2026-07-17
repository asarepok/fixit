import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../utils/extensions.dart';

class PaymentWaitArgs {
  const PaymentWaitArgs({
    required this.bookingId,
    required this.paymentId,
    required this.authorizationUrl,
  });
  final String bookingId;
  final String paymentId;
  final String authorizationUrl;
}

// Where Paystack redirects once checkout finishes, success, failure, or
// cancel, has to match PAYSTACK_CALLBACK_URL in
// functions/src/paystack/client.ts exactly. The page itself never needs
// to load, navigating there at all is the signal checkout is done.
const _callbackUrlPrefix = "https://fixit-74c45.web.app/payment-callback";

// Opens Paystack's actual hosted checkout page in a plain webview. Every
// payment channel (mobile money, card, bank transfer, ...) works here
// since it's the real Paystack checkout, not a native reimplementation
// of it, paystack_flutter_sdk's native UI turned out to only support
// cards. Once the page redirects to the callback URL, this confirms the
// result against the server, a customer reaching that URL doesn't by
// itself prove they paid, see PaymentRepository.checkPaymentStatus.
class PaymentWaitingScreen extends ConsumerStatefulWidget {
  const PaymentWaitingScreen({super.key, required this.args});
  final PaymentWaitArgs args;
  @override
  ConsumerState<PaymentWaitingScreen> createState() =>
      _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends ConsumerState<PaymentWaitingScreen> {
  late final WebViewController _controller;
  bool _confirming = false;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(_callbackUrlPrefix)) {
              _confirm();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.args.authorizationUrl));
  }

  // A short, bounded check, not an open-ended poll. By the time this
  // runs, the checkout page has already redirected back one way or
  // another, this just gives the server a few moments to catch up.
  Future<void> _confirm() async {
    if (_confirming) return;
    setState(() {
      _confirming = true;
      _confirmError = null;
    });

    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final status = await ref
            .read(paymentControllerProvider.notifier)
            .checkStatus(widget.args.bookingId, widget.args.paymentId);
        if (!mounted) return;

        if (status == PaymentStatus.heldInEscrow) {
          context.showSnack('Payment is secured in escrow.');
          Navigator.pop(context);
          return;
        }
        if (status == PaymentStatus.failed) {
          setState(() {
            _confirming = false;
            _confirmError = 'Payment failed. Please try again.';
          });
          return;
        }
      } catch (_) {
        // Keep retrying within the bounded loop below.
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    setState(() {
      _confirming = false;
      _confirmError =
          "Still confirming, this can take a moment. Close and reopen if it doesn't update.";
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pay with Paystack')),
    body: Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_confirming)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Confirming your payment...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_confirmError != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_confirmError!),
              ),
            ),
          ),
      ],
    ),
  );
}
