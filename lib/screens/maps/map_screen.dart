import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/constants.dart';
import '../../app/map_style.dart';
import '../../providers/artisan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';
import '../settings/location_picker_screen.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

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
    // "Nearby" is relative to the customer's own saved location, not a
    // fresh GPS read, see nearbyArtisansProvider. This screen just plots
    // that same location and those same results on a map.
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    final nearbyAsync = ref.watch(nearbyArtisansProvider);
    final hasLocation = user?.latitude != null && user?.longitude != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Artisans')),
      body: !hasLocation
          ? Center(
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
                      "Set your location to see nearby artisans on the map.",
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
            )
          : Builder(
              builder: (context) {
                final customer = LatLng(user!.latitude!, user.longitude!);
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
                  style: mapStyleFor(Theme.of(context).brightness),
                  markers: markers,
                );
              },
            ),
    );
  }
}
