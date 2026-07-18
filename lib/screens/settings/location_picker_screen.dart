import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/map_style.dart';
import '../../providers/location_provider.dart';
import '../../widgets/primary_button.dart';

// Accra, used as the starting point when the device's own GPS isn't
// available (permission denied, location services off), rather than
// leaving the picker with nowhere sensible to open.
const _accra = LatLng(5.6037, -0.1870);

// What the picker hands back: the coordinates to save, plus the address
// already resolved for them while picking, so the caller doesn't have to
// reverse geocode a second time just to show a readable label somewhere.
class PickedLocation {
  const PickedLocation({required this.position, required this.address});
  final LatLng position;
  final String? address;
}

// A Bolt Food-style location picker: the pin stays fixed in the center of
// the screen and the map moves underneath it, rather than a draggable
// marker, with the resolved address shown right above the pin, updating
// once the map settles. Pops with a PickedLocation, or null if the
// customer backs out.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  LatLng? _startingPosition;
  LatLng _center = _accra;
  GoogleMapController? _mapController;
  String? _address;
  bool _resolvingAddress = false;
  final _geocoding = Geocoding();

  @override
  void initState() {
    super.initState();
    _resolveStartingPosition();
  }

  Future<void> _resolveStartingPosition() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _startingPosition = LatLng(position.latitude, position.longitude);
        _center = _startingPosition!;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingPosition = _accra);
    }
    _resolveAddress(_center);
  }

  // Runs once the map settles (onCameraIdle), not on every drag frame,
  // reverse geocoding on every pixel of movement would be both wasteful
  // and janky, this is the same "address catches up a beat after you stop
  // moving" behaviour Bolt Food itself has.
  Future<void> _resolveAddress(LatLng target) async {
    setState(() => _resolvingAddress = true);
    try {
      final placemarks =
          await _geocoding.placemarkFromCoordinates(target.latitude, target.longitude);
      if (!mounted) return;
      final place = placemarks.firstOrNull;
      final line = [
        place?.street,
        place?.subLocality?.isNotEmpty == true ? place?.subLocality : place?.locality,
      ].where((part) => part != null && part.isNotEmpty).join(', ');
      setState(() {
        _address = line.isEmpty ? 'Unknown location' : line;
        _resolvingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address = null;
        _resolvingAddress = false;
      });
    }
  }

  Future<void> _recenterOnMe() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentLocation();
      final target = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(target));
    } catch (_) {
      // Nothing to recenter to, the map just stays where it is.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Your Location')),
      body: _startingPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _startingPosition!, zoom: 16),
                  style: mapStyleFor(Theme.of(context).brightness),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) => _center = position.target,
                  onCameraIdle: () => _resolveAddress(_center),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // The address label and the pin move together, fixed in
                // the center of the screen while the map pans underneath,
                // offset up so the pin's tip, not the label, marks the
                // actual picked point.
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 74),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AddressChip(address: _address, loading: _resolvingAddress),
                          const SizedBox(height: 6),
                          const Icon(Icons.location_pin, size: 44, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 110,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter',
                    onPressed: _recenterOnMe,
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: SafeArea(
                    top: false,
                    child: PrimaryButton(
                      text: 'Confirm This Location',
                      onPressed: () => Navigator.pop(
                        context,
                        PickedLocation(position: _center, address: _address),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AddressChip extends StatelessWidget {
  const _AddressChip({required this.address, required this.loading});
  final String? address;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
            )
          else
            Icon(Icons.place_rounded, size: 14, color: colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              loading ? 'Locating…' : (address ?? "Couldn't find an address here"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
