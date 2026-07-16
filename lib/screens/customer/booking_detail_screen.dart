import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../models/booking_model.dart';
import '../../models/payment_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/payment_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';
import 'payment_waiting_screen.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;
  Future<void> _pay(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    try {
      final paymentId = await ref
          .read(paymentControllerProvider.notifier)
          .initiatePayment(booking.id);
      if (context.mounted)
        context.push(
          AppRoutes.paymentWaiting,
          extra: PaymentWaitArgs(bookingId: booking.id, paymentId: paymentId),
        );
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
      if (context.mounted)
        context.showSnack('Payment released to the artisan.');
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (booking) {
          if (booking == null)
            return const Center(child: Text('Booking not found.'));
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
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                booking.status.value.replaceAll('_', ' ').toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                booking.description,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(booking.location),
              if (booking.amount != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Quote: GH₵ ${booking.amount!.toStringAsFixed(2)}',
                  ),
                ),
              if (booking.paymentStatus != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Payment: ${booking.paymentStatus!.value.replaceAll('_', ' ')}',
                  ),
                ),
              const SizedBox(height: 28),
              if (booking.status == BookingStatus.pending)
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(bookingControllerProvider.notifier)
                          .cancelBooking(booking.id);
                    } catch (error) {
                      if (context.mounted) context.showSnack(error.toString());
                    }
                  },
                  child: const Text('Cancel Request'),
                ),
              if (canPay)
                PrimaryButton(
                  text: 'Pay with MoMo',
                  onPressed: () => _pay(context, ref, booking),
                ),
              if (canRelease)
                PrimaryButton(
                  text: 'Release Payment',
                  onPressed: () => _release(context, ref, booking),
                ),
              if (canContact && booking.chatId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.chatThread,
                      extra: booking.chatId!,
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Message artisan'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
