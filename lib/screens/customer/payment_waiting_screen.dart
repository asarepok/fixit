import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../utils/extensions.dart';

class PaymentWaitArgs {
  const PaymentWaitArgs({required this.bookingId, required this.paymentId});
  final String bookingId;
  final String paymentId;
}

class PaymentWaitingScreen extends ConsumerStatefulWidget {
  const PaymentWaitingScreen({super.key, required this.args});
  final PaymentWaitArgs args;
  @override
  ConsumerState<PaymentWaitingScreen> createState() =>
      _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends ConsumerState<PaymentWaitingScreen> {
  Timer? _timer;
  String _message = 'Confirm the payment on your phone.';
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
    _check();
  }

  Future<void> _check() async {
    try {
      final status = await ref
          .read(paymentControllerProvider.notifier)
          .checkStatus(widget.args.bookingId, widget.args.paymentId);
      if (!mounted) return;
      if (status == PaymentStatus.heldInEscrow) {
        _timer?.cancel();
        context.showSnack('Payment is secured in escrow.');
        Navigator.pop(context);
      } else if (status == PaymentStatus.failed) {
        _timer?.cancel();
        setState(() => _message = 'Payment failed. Please try again.');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Confirm Payment')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
