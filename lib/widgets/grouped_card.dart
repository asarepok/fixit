import 'package:flutter/material.dart';

// A run of related rows in one card, divided by hairlines, instead of
// each row floating in its own bordered box. This is the one grouping
// pattern used everywhere a screen lists several peers of the same kind
// (profile options, artisan results, booking rows): it reads as one
// cohesive list, and it's what Android's own Settings app and most
// Material apps do instead of stacking separate cards with gaps.
class GroupedCard extends StatelessWidget {
  const GroupedCard({super.key, required this.children, this.indent = 0});

  final List<Widget> children;
  final double indent;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, indent: indent),
          children[i],
        ],
      ],
    ),
  );
}
