import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import 'rate_artisan_screen.dart';

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

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = booking.status == BookingStatus.completed;
    final hasReview = completed
        ? ref.watch(hasReviewForBookingProvider(booking.id)).valueOrNull
        : null;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              booking.description.isEmpty ? 'Service request' : booking.description,
            ),
            subtitle: Text(booking.location),
            trailing: StatusChip.booking(booking.status),
            onTap: () => context.push(AppRoutes.bookingDetail, extra: booking.id),
          ),
          // Optional, not a prompt: a completed job just keeps a quiet way
          // to rate it here for whenever the customer feels like it,
          // rather than forcing a review dialog the moment it's done.
          if (completed && hasReview == false)
            _RateRow(
              onTap: () {
                final artisan =
                    ref.read(userByIdProvider(booking.artisanId)).valueOrNull;
                context.push(
                  AppRoutes.rateArtisan,
                  extra: RateArtisanArgs(
                    bookingId: booking.id,
                    artisanName: artisan?.name.isNotEmpty == true
                        ? artisan!.name
                        : 'the artisan',
                  ),
                );
              },
            )
          else if (completed && hasReview == true)
            const _ReviewedRow(),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(Icons.star_outline_rounded, size: 17, color: AppColors.accentOf(context)),
          const SizedBox(width: 6),
          Text(
            'Rate this job',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accentOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReviewedRow extends StatelessWidget {
  const _ReviewedRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 17, color: AppColors.accentOf(context)),
          const SizedBox(width: 6),
          Text(
            'Reviewed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();
  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.event_note_outlined,
    title: 'No bookings yet',
    message: 'Once you request a service, it will show up here.',
  );
}
