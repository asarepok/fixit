import 'package:flutter/material.dart';

// A tab icon with a small count badge in the corner, hidden entirely when
// count is 0 so an empty tab looks the same as it always did. Used on the
// customer and artisan bottom nav bars to show things like active bookings
// or open chat threads.
class BadgedIcon extends StatelessWidget {
  const BadgedIcon({super.key, required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) => Badge(
    label: Text(count > 99 ? '99+' : '$count'),
    isLabelVisible: count > 0,
    child: Icon(icon),
  );
}
