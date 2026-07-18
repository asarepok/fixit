import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/artisan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../widgets/artisan_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/grouped_card.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/service_category_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    final artisans = ref.watch(artisansProvider);
    final mode = ref.watch(appModeProvider);
    final nameParts = user?.name.trim().split(RegExp(r'\s+')) ?? const [];
    final greetingName = nameParts.isEmpty || nameParts.first.isEmpty
        ? 'there'
        : nameParts.first;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(artisansProvider),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Hi, $greetingName',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.map_outlined,
                    tooltip: 'Map',
                    onTap: () => context.push(AppRoutes.map),
                  ),
                  if (user?.isArtisan == true) ...[
                    const SizedBox(width: 10),
                    _HeaderIconButton(
                      icon: Icons.swap_horiz_rounded,
                      tooltip: mode == AppMode.artisan
                          ? 'Working'
                          : 'Switch to Working',
                      onTap: () {
                        ref.read(appModeProvider.notifier).state =
                            AppMode.artisan;
                        context.go(AppRoutes.artisanDashboard);
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              SearchBar(
                hintText: 'Search artisans or services',
                leading: const Icon(Icons.search_rounded),
                onTap: () => context.push(AppRoutes.search),
                elevation: const WidgetStatePropertyAll(0),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeading(eyebrow: 'Browse', title: 'Categories'),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ServiceCategoryCard(
                      icon: Icons.electrical_services_outlined,
                      title: 'Electrician',
                      onTap: () =>
                          context.push(AppRoutes.search, extra: 'electrician'),
                    ),
                    const SizedBox(width: 12),
                    ServiceCategoryCard(
                      icon: Icons.plumbing_outlined,
                      title: 'Plumber',
                      onTap: () =>
                          context.push(AppRoutes.search, extra: 'plumber'),
                    ),
                    const SizedBox(width: 12),
                    ServiceCategoryCard(
                      icon: Icons.build_outlined,
                      title: 'Mechanic',
                      onTap: () =>
                          context.push(AppRoutes.search, extra: 'mechanic'),
                    ),
                    const SizedBox(width: 12),
                    ServiceCategoryCard(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Cleaner',
                      onTap: () =>
                          context.push(AppRoutes.search, extra: 'cleaner'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SectionHeading(
                eyebrow: 'Nearby & top rated',
                title: 'Featured artisans',
                action: 'Nearest',
                onActionTap: () => context.push(AppRoutes.nearbyArtisans),
              ),
              const SizedBox(height: 10),
              artisans.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => const _EmptyArtisans(
                  message: 'Unable to load artisans right now.',
                ),
                data: (list) {
                  final featured = list
                      .where((artisan) => artisan.uid != user?.uid)
                      .take(4)
                      .toList();
                  if (featured.isEmpty) {
                    return const _EmptyArtisans(
                      message: 'No verified artisans are available yet.',
                    );
                  }
                  return GroupedCard(
                    indent: 78,
                    children: featured
                        .map(
                          (artisan) => ArtisanCard(
                            artisan: artisan,
                            onTap: () => context.push(
                              AppRoutes.artisanProfile,
                              extra: artisan,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A compact circular affordance for a header shortcut, used for both the
// map and jumping into artisan mode, rather than full text buttons
// competing with the headline for space.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }
}

class _EmptyArtisans extends StatelessWidget {
  const _EmptyArtisans({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.handyman_outlined,
    title: 'No artisans yet',
    message: message,
  );
}
