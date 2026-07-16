import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/location_provider.dart';

// Shows the device's current position on a Google Map. Reads the position
// through currentPositionProvider instead of creating LocationService
// itself, so a permission error shows as a normal error message below
// rather than the screen getting stuck loading.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FixIt Map"),
      ),
      body: positionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (position) {
          final currentLocation = LatLng(position.latitude, position.longitude);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("customer"),
                position: currentLocation,
                infoWindow: const InfoWindow(title: "Your Location"),
              ),
            },
          );
        },
      ),
    );
  }
}
