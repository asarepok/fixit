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
import '../../utils/helpers.dart';
import '../../widgets/badged_icon.dart';
import '../../widgets/detail_line.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/grouped_card.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/user_name_label.dart';
import '../chat/chat_screen.dart';
import '../customer/profile_screen.dart';

class ArtisanDashboardScreen extends ConsumerStatefulWidget {
  const ArtisanDashboardScreen({super.key});
  @override
  ConsumerState<ArtisanDashboardScreen> createState() =>
      _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState
    extends ConsumerState<ArtisanDashboardScreen> {
  int _tab = 0;
  static const _labels = ['Dashboard', 'Requests', 'Jobs', 'Chat', 'Profile'];

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
      0 => _DashboardTab(
          user: user,
          requestsCount: requestsCount,
          jobsCount: jobsCount,
          onSeeRequests: () => setState(() => _tab = 1),
          onSeeJobs: () => setState(() => _tab = 2),
        ),
      1 => const _RequestsTab(),
      2 => const _JobsTab(),
      3 => const ChatThreadsList(),
      _ => const ProfileScreen(),
    };

    // Profile brings its own AppBar (it's the same screen a customer
    // sees), so the shell's own bar, which exists for the per-tab title
    // and the mode-switch action, steps aside rather than stacking a
    // second bar on top of it.
    return Scaffold(
      appBar: _tab == 4
          ? null
          : AppBar(
              title: Text(_labels[_tab]),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    ref.read(appModeProvider.notifier).state = AppMode.customer;
                    context.go(AppRoutes.home);
                  },
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Booking'),
                ),
              ],
            ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
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

// Tab 0: the overview an artisan lands on, a greeting, earnings, rating,
// and a glance at what's waiting elsewhere, each summary row jumps
// straight to the tab it's summarizing. Deliberately separate from the
// Requests tab: this is for checking in, Requests is for acting.
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab({
    required this.user,
    required this.requestsCount,
    required this.jobsCount,
    required this.onSeeRequests,
    required this.onSeeJobs,
  });

  final UserModel? user;
  final int requestsCount;
  final int jobsCount;
  final VoidCallback onSeeRequests;
  final VoidCallback onSeeJobs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name.isNotEmpty == true ? user!.name : 'Artisan';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 18),
        _BalanceCard(
          balance: user?.balance ?? 0,
          rating: user?.averageRating,
          reviewCount: user?.ratingCount,
        ),
        const SizedBox(height: 22),
        const SectionHeading(eyebrow: 'At a glance', title: 'Needs your attention'),
        const SizedBox(height: 12),
        GroupedCard(
          indent: 56,
          children: [
            _GlanceRow(
              icon: Icons.notifications_none,
              title: 'New requests',
              count: requestsCount,
              onTap: onSeeRequests,
            ),
            _GlanceRow(
              icon: Icons.work_outline,
              title: 'Active jobs',
              count: jobsCount,
              onTap: onSeeJobs,
            ),
          ],
        ),
      ],
    );
  }
}

// A tappable summary row: a count and where to go to act on it. Reads as
// "here's what needs you," each row's own tab is where the actual list
// and actions (Accept/Decline, Start/Complete) live.
class _GlanceRow extends StatelessWidget {
  const _GlanceRow({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            )
          else
            Text('None', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

// Tab 1: purely the actionable queue, pending requests waiting on Accept
// (asks for a quote) or Decline. No balance, no stats, just the work.
class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(artisanRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(artisanRequestsProvider),
      child: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No new requests',
              message: 'New booking requests will show up here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) => _RequestCard(booking: requests[index]),
          );
        },
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
            Row(
              children: [
                UserAvatar(uid: widget.booking.customerId, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: UserNameLabel(
                    uid: widget.booking.customerId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (widget.booking.createdAt != null)
                  Text(
                    timeAgo(widget.booking.createdAt!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.booking.description),
            const SizedBox(height: 6),
            DetailLine(icon: Icons.location_on_outlined, text: widget.booking.location),
            const SizedBox(height: 16),
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
                        child: FilledButton(
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
          return const EmptyState(
            icon: Icons.work_outline,
            title: 'No active jobs',
            message: 'Accepted requests you start work on will show up here.',
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
      if (mounted) context.showSnack('Marked as done!');
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
            Row(
              children: [
                UserAvatar(uid: booking.customerId, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: UserNameLabel(
                    uid: booking.customerId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusChip.booking(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(booking.description),
            const SizedBox(height: 6),
            DetailLine(icon: Icons.location_on_outlined, text: booking.location),
            const SizedBox(height: 14),
            if (waitingOnPayment)
              Text(
                "Waiting for the customer to pay before you can start.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (_loading && (canStart || canComplete))
              const Center(child: CircularProgressIndicator())
            else ...[
              if (canStart)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _start,
                    child: const Text('Start Job'),
                  ),
                ),
              if (canComplete)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _complete,
                    child: const Text('Mark as Done'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// The earnings hero: the number an artisan opens this tab to check. Sits
// on the primary color so it reads as the one thing on this screen that
// matters most. Rating and review count ride along as secondary stats in
// the same card, they're the other two numbers that describe "how am I
// doing," not actionable items like the glance rows below.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.rating,
    required this.reviewCount,
  });
  final double balance;
  final double? rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: colorScheme.onPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'GH₵ ${balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: colorScheme.onPrimary.withValues(alpha: 0.18)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  icon: Icons.star_rounded,
                  value: rating != null ? rating!.toStringAsFixed(1) : '—',
                  label: 'Rating',
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: colorScheme.onPrimary.withValues(alpha: 0.18),
              ),
              Expanded(
                child: _BalanceStat(
                  icon: Icons.reviews_rounded,
                  value: reviewCount != null ? '$reviewCount' : '—',
                  label: 'Reviews',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.onPrimary.withValues(alpha: 0.85), size: 16),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
