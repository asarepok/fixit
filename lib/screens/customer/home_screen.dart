import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/artisan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../widgets/artisan_card.dart';
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FixIt GH',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hi, $greetingName',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (user?.isArtisan == true)
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(appModeProvider.notifier).state =
                            AppMode.artisan;
                        context.go(AppRoutes.artisanDashboard);
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: Text(
                        mode == AppMode.artisan
                            ? 'Artisan mode'
                            : 'Switch to Artisan',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                readOnly: true,
                onTap: () => context.push(AppRoutes.search),
                decoration: const InputDecoration(
                  hintText: 'Search artisans or services',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 104,
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
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Featured artisans',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.nearbyArtisans),
                    child: const Text('Nearest'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              artisans.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => const _EmptyArtisans(
                  message: 'Unable to load artisans right now.',
                ),
                data: (list) => list.isEmpty
                    ? const _EmptyArtisans(
                        message: 'No verified artisans are available yet.',
                      )
                    : Column(
                        children: list
                            .where((artisan) => artisan.uid != user?.uid)
                            .take(4)
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyArtisans extends StatelessWidget {
  const _EmptyArtisans({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Center(
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    ),
  );
}
