import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/booking_provider.dart';
import '../../widgets/status_chip.dart';

class ManageBookingsScreen extends ConsumerWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(allBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final booking = items[index];
              return Card(
                child: ListTile(
                  title: Text(
                    booking.description.isEmpty
                        ? 'Service request'
                        : booking.description,
                  ),
                  subtitle: Text(
                    '${booking.location}\nCustomer: ${booking.customerId}',
                  ),
                  isThreeLine: true,
                  trailing: StatusChip.booking(booking.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
