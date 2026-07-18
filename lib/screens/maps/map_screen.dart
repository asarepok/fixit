import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/constants.dart';
import '../../providers/artisan_provider.dart';
import '../../providers/location_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);
    final nearbyAsync = ref.watch(nearbyArtisansProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Artisans')),
      body: positionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                  "We need your location to show nearby artisans on the map.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => ref.invalidate(currentPositionProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (position) {
          final customer = LatLng(position.latitude, position.longitude);
          final markers = <Marker>{
            Marker(
              markerId: const MarkerId('customer'),
              position: customer,
              infoWindow: const InfoWindow(title: 'Your location'),
            ),
          };
          for (final entry in nearbyAsync.valueOrNull ?? []) {
            final artisan = entry.artisan;
            markers.add(
              Marker(
                markerId: MarkerId(artisan.uid),
                position: LatLng(artisan.latitude!, artisan.longitude!),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
                infoWindow: InfoWindow(
                  title: artisan.name,
                  snippet: '${entry.distanceKm.toStringAsFixed(1)} km away',
                ),
                onTap: () =>
                    context.push(AppRoutes.artisanProfile, extra: artisan),
              ),
            );
          }
          return GoogleMap(
            initialCameraPosition: CameraPosition(target: customer, zoom: 13.5),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
          );
        },
      ),
    );
  }
}
