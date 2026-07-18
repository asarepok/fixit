import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';

class ManagePaymentsScreen extends ConsumerWidget {
  const ManagePaymentsScreen({super.key});
  Future<void> _refund(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
    String paymentId,
  ) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Refund payment'),
        content: TextField(
          controller: reason,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(paymentControllerProvider.notifier)
          .refund(bookingId, paymentId, reason: reason.text.trim());
      if (context.mounted) context.showSnack('Refund requested.');
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    } finally {
      reason.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(allPaymentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Payments')),
      body: payments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const EmptyState(
                icon: Icons.payments_outlined,
                title: 'No payments found',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final payment = items[index];
                  final canRefund =
                      payment.status.name != 'refunded' &&
                      payment.status.name != 'failed';
                  return Card(
                    child: ListTile(
                      title: Text('GH₵ ${payment.amount.toStringAsFixed(2)}'),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Booking: ${payment.bookingId}'),
                            const SizedBox(height: 6),
                            StatusChip.payment(payment.status),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                      trailing: canRefund
                          ? TextButton(
                              onPressed: () => _refund(
                                context,
                                ref,
                                payment.bookingId,
                                payment.id,
                              ),
                              child: const Text('Refund'),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
