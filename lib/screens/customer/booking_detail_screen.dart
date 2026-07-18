import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../models/booking_model.dart';
import '../../models/payment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/booking_progress.dart';
import '../../widgets/detail_line.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import 'payment_waiting_screen.dart';
import 'rate_artisan_screen.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;
  Future<void> _pay(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    try {
      final initiation = await ref
          .read(paymentControllerProvider.notifier)
          .initiatePayment(booking.id);
      if (context.mounted) {
        context.push(
          AppRoutes.paymentWaiting,
          extra: PaymentWaitArgs(
            bookingId: booking.id,
            paymentId: initiation.paymentId,
            authorizationUrl: initiation.authorizationUrl,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    }
  }

  Future<void> _release(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    try {
      await ref
          .read(paymentControllerProvider.notifier)
          .releaseEscrow(booking.id, booking.paymentId!);
      if (context.mounted) {
        context.showSnack('Payment sent to the artisan!');
      }
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    }
  }

  // What's actually happening right now, and what the customer needs to
  // do about it, if anything, in one plain sentence. The stepper alone
  // only names the state, this is what it means for them, said the way
  // you'd tell a friend, not the way the database would.
  String _statusBlurb(Booking booking, {required bool canPay, required bool canRelease}) {
    switch (booking.status) {
      case BookingStatus.pending:
        return "Sent! We'll let you know as soon as the artisan responds.";
      case BookingStatus.accepted:
        if (canPay) return "They've sent a quote. Pay to lock in the job.";
        if (booking.paymentStatus == PaymentStatus.heldInEscrow) {
          return "You're all set. The artisan will start soon.";
        }
        return "Just a moment, confirming your payment.";
      case BookingStatus.inProgress:
        return "The artisan is working on your job right now.";
      case BookingStatus.completed:
        if (canRelease) {
          return "The job's done. Happy with the work? Pay the artisan to wrap up.";
        }
        if (booking.paymentStatus == PaymentStatus.released) {
          return "All done. The artisan has been paid.";
        }
        return "This job is complete.";
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return "";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingProvider(bookingId));
    final paymentLoading = ref.watch(paymentControllerProvider).isLoading;
    final bookingLoading = ref.watch(bookingControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found.'));
          }
          final canContact =
              booking.status == BookingStatus.accepted ||
              booking.status == BookingStatus.inProgress;
          final canPay =
              booking.status == BookingStatus.accepted &&
              booking.paymentStatus != PaymentStatus.heldInEscrow &&
              booking.paymentStatus != PaymentStatus.released;
          final canRelease =
              booking.status == BookingStatus.completed &&
              booking.paymentStatus == PaymentStatus.heldInEscrow &&
              booking.paymentId != null;
          final isDeadEnd = booking.status == BookingStatus.declined ||
              booking.status == BookingStatus.cancelled;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: isDeadEnd
                      ? Row(
                          children: [
                            StatusChip.booking(booking.status),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                booking.status == BookingStatus.declined
                                    ? 'The artisan declined this request.'
                                    : 'This request was cancelled.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            BookingProgress(status: booking.status),
                            const SizedBox(height: 16),
                            Text(
                              _statusBlurb(
                                booking,
                                canPay: canPay,
                                canRelease: canRelease,
                              ),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.description,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (booking.paymentStatus != null) ...[
                            const SizedBox(width: 8),
                            StatusChip.payment(booking.paymentStatus!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      DetailLine(icon: Icons.location_on_outlined, text: booking.location),
                      if (booking.amount != null) ...[
                        const SizedBox(height: 10),
                        DetailLine(
                          icon: Icons.payments_outlined,
                          text: 'Quote: GH₵ ${booking.amount!.toStringAsFixed(2)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (booking.status == BookingStatus.pending)
                bookingLoading
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(bookingControllerProvider.notifier)
                                .cancelBooking(booking.id);
                          } catch (error) {
                            if (context.mounted) {
                              context.showSnack(error.toString());
                            }
                          }
                        },
                        child: const Text('Cancel Request'),
                      ),
              if (canPay)
                paymentLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Pay',
                        onPressed: () => _pay(context, ref, booking),
                      ),
              if (canRelease)
                paymentLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Pay Artisan',
                        onPressed: () => _release(context, ref, booking),
                      ),
              if (booking.status == BookingStatus.completed)
                _RateArtisanButton(booking: booking),
              if (canContact && booking.chatId != null) ...[
                const SizedBox(height: 14),
                _ContactBar(
                  onTap: () => context.push(
                    AppRoutes.chatThread,
                    extra: booking.chatId!,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// Only renders once the booking is completed and only if this customer
// hasn't already reviewed it, since the Cloud Function would reject a
// second one anyway, no point offering a button that always fails.
class _RateArtisanButton extends ConsumerWidget {
  const _RateArtisanButton({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alreadyReviewed =
        ref.watch(hasReviewForBookingProvider(booking.id)).valueOrNull;
    if (alreadyReviewed != false) return const SizedBox.shrink();

    final artisan = ref.watch(userByIdProvider(booking.artisanId)).valueOrNull;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: () => context.push(
          AppRoutes.rateArtisan,
          extra: RateArtisanArgs(
            bookingId: booking.id,
            artisanName: artisan?.name.isNotEmpty == true
                ? artisan!.name
                : 'the artisan',
          ),
        ),
        icon: const Icon(Icons.star_outline_rounded),
        label: const Text('Rate Artisan'),
      ),
    );
  }
}

// A persistent way to reach the artisan while a job is live, rather than
// just another outlined button in the pile of actions, this is the one
// row a customer comes back to repeatedly during accepted/in-progress.
class _ContactBar extends StatelessWidget {
  const _ContactBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Message artisan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
