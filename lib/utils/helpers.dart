import 'dart:math';

// Straight-line distance between two GPS points in kilometers, using the
// haversine formula. Used by ArtisanRepository.getNearbyArtisans to sort
// artisans by how close they are.
double calculateDistanceKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadius = 6371; // KM

  double dLat = _degreeToRadian(lat2 - lat1);
  double dLon = _degreeToRadian(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreeToRadian(lat1)) *
          cos(_degreeToRadian(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degreeToRadian(double degree) {
  return degree * pi / 180;
}

// A short "how long ago" caption for a timestamp, e.g. a booking request,
// so a list of them reads by freshness at a glance instead of forcing a
// full date scan to tell which one just came in.
String timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

// A short clock time for a chat message, e.g. "9:05 AM", local time,
// 12-hour clock. No intl dependency needed for something this small.
String messageTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour24 = local.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}
