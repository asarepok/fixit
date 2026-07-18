import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../models/booking_model.dart';
import '../../models/payment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/badged_icon.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_name_label.dart';
import '../chat/chat_screen.dart';

class ArtisanDashboardScreen extends ConsumerStatefulWidget {
  const ArtisanDashboardScreen({super.key});
  @override
  ConsumerState<ArtisanDashboardScreen> createState() =>
      _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState
    extends ConsumerState<ArtisanDashboardScreen> {
  int _tab = 0;
  static const _labels = ['Requests', 'Jobs', 'Earnings', 'Chat', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    if (user != null && !user.isArtisan) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artisan Dashboard')),
        body: const Center(
          child: Text(
            'Your artisan application must be verified before you can use artisan mode.',
          ),
        ),
      );
    }
    final requestsCount = ref.watch(artisanRequestsProvider).valueOrNull?.length ?? 0;
    final jobsCount = ref.watch(artisanJobsProvider).valueOrNull?.length ?? 0;
    final chatCount = ref.watch(myChatsProvider).valueOrNull?.length ?? 0;

    final Widget body = switch (_tab) {
      0 => _RequestsTab(user: user, requestsCount: requestsCount, jobsCount: jobsCount),
      1 => const _JobsTab(),
      3 => const ChatThreadsList(),
      _ => const _UnavailableWork(
          message: 'Earnings will appear here once payout history is tracked.',
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Artisan Dashboard' : _labels[_tab]),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(appModeProvider.notifier).state = AppMode.customer;
              context.go(AppRoutes.home);
            },
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            label: const Text(
              'Customer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          if (index == 4) {
            context.push(AppRoutes.profile);
          } else {
            setState(() => _tab = index);
          }
        },
        destinations: [
          NavigationDestination(
            icon: BadgedIcon(
              icon: Icons.notifications_none,
              count: requestsCount,
            ),
            selectedIcon: BadgedIcon(
              icon: Icons.notifications,
              count: requestsCount,
            ),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: BadgedIcon(icon: Icons.work_outline, count: jobsCount),
            selectedIcon: BadgedIcon(icon: Icons.work, count: jobsCount),
            label: 'Jobs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: BadgedIcon(icon: Icons.chat_outlined, count: chatCount),
            selectedIcon: BadgedIcon(icon: Icons.chat, count: chatCount),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Tab 0: a greeting, a few real counts, and the actual pending requests
// waiting on this artisan, with Accept (asks for a quote) and Decline.
class _RequestsTab extends ConsumerWidget {
  const _RequestsTab({
    required this.user,
    required this.requestsCount,
    required this.jobsCount,
  });

  final UserModel? user;
  final int requestsCount;
  final int jobsCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(artisanRequestsProvider);
    final name = user?.name.isNotEmpty == true ? user!.name : 'Artisan';

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(artisanRequestsProvider),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Manage your service work in one place.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available balance',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GH₵ ${(user?.balance ?? 0).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _Metric(
                label: 'New requests',
                value: '$requestsCount',
                icon: Icons.notifications_none,
              ),
              _Metric(
                label: 'Active jobs',
                value: '$jobsCount',
                icon: Icons.work_outline,
              ),
              _Metric(
                label: 'Rating',
                value: user?.averageRating != null
                    ? user!.averageRating!.toStringAsFixed(1)
                    : '—',
                icon: Icons.star_outline,
              ),
              _Metric(
                label: 'Reviews',
                value: user?.ratingCount != null ? '${user!.ratingCount}' : '—',
                icon: Icons.reviews_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('New requests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          requestsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text(error.toString()),
            data: (requests) {
              if (requests.isEmpty) {
                return Text(
                  'No new requests right now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }
              return Column(
                children: requests
                    .map((booking) => _RequestCard(booking: booking))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// One request's card, with its own loading state, so accepting or
// declining one request only shows that card as busy, not every request
// in the list.
class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.booking});
  final Booking booking;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _loading = false;

  Future<void> _accept() async {
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Quote a price'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: 'GH₵ ', hintText: 'Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, double.tryParse(controller.text.trim())),
              child: const Text('Send Quote'),
            ),
          ],
        );
      },
    );
    if (amount == null || amount <= 0) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(bookingControllerProvider.notifier)
          .acceptBooking(widget.booking.id, amount);
      if (mounted) context.showSnack('Request accepted, quote sent.');
    } catch (error) {
      if (mounted) context.showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decline() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline this request?'),
        content: const Text('The customer will need to book someone else.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(bookingControllerProvider.notifier)
          .declineBooking(widget.booking.id);
      if (mounted) context.showSnack('Request declined.');
    } catch (error) {
      if (mounted) context.showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserNameLabel(
              uid: widget.booking.customerId,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(widget.booking.description),
            const SizedBox(height: 4),
            Text(
              widget.booking.location,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _decline,
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _accept,
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// Tab 1: accepted/in-progress bookings, with Start Job (once payment is
// held in escrow) and Mark Complete.
class _JobsTab extends ConsumerWidget {
  const _JobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(artisanJobsProvider);

    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
      data: (jobs) {
        if (jobs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No active jobs right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(artisanJobsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: jobs.length,
            itemBuilder: (context, index) => _JobCard(booking: jobs[index]),
          ),
        );
      },
    );
  }
}

// One job's card, with its own loading state, so starting or completing
// one job only shows that card as busy, not every job in the list.
class _JobCard extends ConsumerStatefulWidget {
  const _JobCard({required this.booking});
  final Booking booking;

  @override
  ConsumerState<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends ConsumerState<_JobCard> {
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      await ref.read(bookingControllerProvider.notifier).startJob(widget.booking.id);
      if (mounted) context.showSnack('Job started.');
    } catch (error) {
      if (mounted) context.showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await ref.read(bookingControllerProvider.notifier).completeJob(widget.booking.id);
      if (mounted) context.showSnack('Job marked complete.');
    } catch (error) {
      if (mounted) context.showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final canStart = booking.status == BookingStatus.accepted &&
        booking.paymentStatus == PaymentStatus.heldInEscrow;
    final waitingOnPayment = booking.status == BookingStatus.accepted &&
        booking.paymentStatus != PaymentStatus.heldInEscrow;
    final canComplete = booking.status == BookingStatus.inProgress;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserNameLabel(
              uid: booking.customerId,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(booking.description),
            const SizedBox(height: 4),
            Text(
              booking.location,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            StatusChip.booking(booking.status),
            const SizedBox(height: 14),
            if (waitingOnPayment)
              Text(
                'Waiting for the customer to pay into escrow.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (_loading && (canStart || canComplete))
              const Center(child: CircularProgressIndicator())
            else ...[
              if (canStart)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _start,
                    child: const Text('Start Job'),
                  ),
                ),
              if (canComplete)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _complete,
                    child: const Text('Mark Complete'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class _UnavailableWork extends StatelessWidget {
  const _UnavailableWork({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
