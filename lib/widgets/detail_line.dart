import 'package:flutter/material.dart';

// A small icon + text row: a location, a quote, a note. The one way this
// app pairs a glyph with a fact everywhere it needs to (booking detail,
// dashboard cards), instead of every screen inventing its own spacing.
class DetailLine extends StatelessWidget {
  const DetailLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
    ],
  );
}
