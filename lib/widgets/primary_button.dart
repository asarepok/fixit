import 'package:flutter/material.dart';

import '../app/theme.dart';

// The one highest-emphasis action on a screen: pay, submit, book, confirm.
// Always the warm accent color and always full width, so it reads the
// same way everywhere a user needs to know exactly what to tap next.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentOf(context);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: accent.withValues(alpha: 0.4),
        ),
        child: Text(text),
      ),
    );
  }
}
