import 'package:flutter/material.dart';

// A flat, minimal map style in the vein of Uber/Yango: no POI clutter, no
// transit lines, muted roads, a quiet neutral background so the pins
// (your location, nearby artisans) are the only thing that actually
// draws the eye. Google Maps JSON styling, the same mechanism the Maps
// Platform styling wizard and Snazzy Maps both produce, applied via
// GoogleMap's own style parameter, no extra package needed.
const _lightMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#f5f5f5"}]},
  {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.neighborhood", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"color": "#e0e0e0"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#e6ebe4"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#e8e8e8"}]},
  {"featureType": "road", "elementType": "labels", "stylers": [{"visibility": "simplified"}]},
  {"featureType": "road.arterial", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#dadada"}]},
  {"featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
  {"featureType": "road.local", "elementType": "labels", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#c6dbe8"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#8ea9bd"}]}
]
''';

const _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#1c2025"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8a8f98"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#1c2025"}]},
  {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.neighborhood", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"color": "#2c3239"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#232922"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2c3239"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#23272d"}]},
  {"featureType": "road", "elementType": "labels", "stylers": [{"visibility": "simplified"}]},
  {"featureType": "road.arterial", "elementType": "labels.text.fill", "stylers": [{"color": "#7d848d"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3a414a"}]},
  {"featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [{"color": "#c9ccd1"}]},
  {"featureType": "road.local", "elementType": "labels", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#151a20"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#4d5865"}]}
]
''';

String mapStyleFor(Brightness brightness) =>
    brightness == Brightness.dark ? _darkMapStyle : _lightMapStyle;
