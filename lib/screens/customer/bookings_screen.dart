import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/constants.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/status_chip.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const _EmptyBookings()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myBookingsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _BookingCard(booking: items[index]),
                ),
              ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(
        booking.description.isEmpty ? 'Service request' : booking.description,
      ),
      subtitle: Text(booking.location),
      trailing: StatusChip.booking(booking.status),
      onTap: () => context.push(AppRoutes.bookingDetail, extra: booking.id),
    ),
  );
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'No bookings yet',
      style: Theme.of(context).textTheme.titleLarge,
    ),
  );
}
