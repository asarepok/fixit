import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/artisan_provider.dart';

// Lists artisans sorted by distance from the device. All the location
// reading, Firestore query, and distance sorting happen in
// nearbyArtisansProvider (through ArtisanRepository.getNearbyArtisans),
// this screen only renders the list it gets back.
class NearbyArtisansScreen extends ConsumerWidget {
  const NearbyArtisansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyArtisansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Artisans"),
      ),
      body: nearbyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Shown for both a real error (e.g. location permission denied)
        // and a successful empty list, matching the empty case below.
        error: (error, stack) => const Center(child: Text("No artisans nearby")),
        data: (nearby) {
          if (nearby.isEmpty) {
            return const Center(child: Text("No artisans nearby"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: nearby.length,
            itemBuilder: (context, index) {
              final entry = nearby[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.handyman),
                  ),
                  title: Text(
                    entry.artisan.name.isEmpty ? "Unknown Artisan" : entry.artisan.name,
                  ),
                  subtitle: Text(
                    "${entry.distanceKm.toStringAsFixed(2)} km away",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
