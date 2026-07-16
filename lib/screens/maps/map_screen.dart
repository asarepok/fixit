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
      appBar: AppBar(title: const Text('FixIt Map')),
      body: positionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Location is needed to show nearby artisans.\n$error',
              textAlign: TextAlign.center,
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
