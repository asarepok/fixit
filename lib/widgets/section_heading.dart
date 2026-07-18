import 'package:flutter/material.dart';

// A small uppercase eyebrow label above a section title, with an optional
// trailing action (a "see all"/"nearest" link). The eyebrow is what makes
// a screen with several stacked sections easy to scan, it's a label for
// the section, not a repeat of the title.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.action,
    this.onActionTap,
  });

  final String eyebrow;
  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (action != null)
          TextButton(onPressed: onActionTap, child: Text(action!)),
      ],
    );
  }
}
