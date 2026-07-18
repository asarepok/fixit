import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/artisan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/artisan_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../settings/location_picker_screen.dart';

// Lists artisans sorted by distance from the customer's own saved
// location. All the Firestore query and distance sorting happen in
// nearbyArtisansProvider (through ArtisanRepository.getNearbyArtisans),
// this screen only renders the list it gets back.
class NearbyArtisansScreen extends ConsumerWidget {
  const NearbyArtisansScreen({super.key});

  Future<void> _setLocation(BuildContext context, WidgetRef ref) async {
    final picked = await context.push<PickedLocation>(AppRoutes.locationPicker);
    if (picked == null) return;
    try {
      await ref.read(authControllerProvider.notifier).updateMyLocation(
            picked.position.latitude,
            picked.position.longitude,
            label: picked.address,
          );
      if (context.mounted) context.showSnack('Location updated.');
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyArtisansProvider);
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    final hasLocation = currentUser?.latitude != null && currentUser?.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Artisans"),
        actions: [
          IconButton(
            tooltip: 'View map',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push(AppRoutes.map),
          ),
        ],
      ),
      body: nearbyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => hasLocation
            ? const EmptyState(
                icon: Icons.handyman_outlined,
                title: 'No artisans nearby',
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Set your location to see nearby artisans.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        text: 'Set My Location',
                        onPressed: () => _setLocation(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
        data: (nearby) {
          final available = nearby
              .where((entry) => entry.artisan.uid != currentUser?.uid)
              .toList();
          if (available.isEmpty) {
            return const EmptyState(
              icon: Icons.handyman_outlined,
              title: 'No artisans nearby',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: available.length,
            itemBuilder: (context, index) {
              final entry = available[index];

              return ArtisanCard(
                artisan: entry.artisan,
                distanceKm: entry.distanceKm,
                onTap: () => context.push(
                  AppRoutes.artisanProfile,
                  extra: entry.artisan,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
