import 'dart:math' as math;

import 'package:flutter/material.dart';

// Line-art onboarding illustrations matching the logo's own look: a neutral
// outline (theme-aware, so it stays legible in dark mode) plus the one fixed
// brand accent, orange, sampled from assets/images/fixit_logo.png. No filled
// backdrop shape, kept flat/deliberately simple after the splash screen
// taught us circle backdrops behind the brand marks read wrong.
const _orange = Color(0xFFFF6300);

enum OnboardingIllustrationType { findArtisans, bookEasily, trust }

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration(this.type, {super.key, this.size = 160});

  final OnboardingIllustrationType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final structure = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IllustrationPainter(type, structure),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter(this.type, this.structure);

  final OnboardingIllustrationType type;
  final Color structure;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case OnboardingIllustrationType.findArtisans:
        _paintFindArtisans(canvas, size);
      case OnboardingIllustrationType.bookEasily:
        _paintBookEasily(canvas, size);
      case OnboardingIllustrationType.trust:
        _paintTrust(canvas, size);
    }
  }

  void _paintFindArtisans(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.055;
    final structureStroke = Paint()
      ..color = structure
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final orangeStroke = Paint()
      ..color = _orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final lensCenter = Offset(size.width * 0.40, size.height * 0.40);
    final lensRadius = size.width * 0.22;
    canvas.drawCircle(lensCenter, lensRadius, structureStroke);

    final handleStart = Offset(
      lensCenter.dx + lensRadius * 0.75,
      lensCenter.dy + lensRadius * 0.75,
    );
    final handleEnd = Offset(size.width * 0.76, size.height * 0.76);
    canvas.drawLine(handleStart, handleEnd, orangeStroke);
  }

  void _paintBookEasily(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.018;
    final structureStroke = Paint()
      ..color = structure
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final cardRect = Rect.fromLTWH(
      size.width * 0.26,
      size.height * 0.18,
      size.width * 0.48,
      size.height * 0.58,
    );
    final cardRRect = RRect.fromRectAndRadius(
      cardRect,
      Radius.circular(size.width * 0.06),
    );
    canvas.drawRRect(cardRRect, structureStroke);

    final headerY = cardRect.top + cardRect.height * 0.26;
    canvas.drawLine(
      Offset(cardRect.left, headerY),
      Offset(cardRect.right, headerY),
      structureStroke,
    );
    for (final tabFraction in [0.35, 0.65]) {
      final tx = cardRect.left + cardRect.width * tabFraction;
      canvas.drawLine(
        Offset(tx, cardRect.top - size.height * 0.03),
        Offset(tx, headerY + size.height * 0.03),
        structureStroke,
      );
    }

    final dotPaint = Paint()..color = structure;
    for (var col = 0; col < 3; col++) {
      canvas.drawCircle(
        Offset(
          cardRect.left + cardRect.width * (0.24 + col * 0.26),
          cardRect.top + cardRect.height * 0.68,
        ),
        size.width * 0.024,
        dotPaint,
      );
    }

    final badgeCenter = Offset(
      cardRect.right - size.width * 0.03,
      cardRect.bottom - size.width * 0.03,
    );
    canvas.drawCircle(badgeCenter, size.width * 0.14, Paint()..color = _orange);
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(badgeCenter.dx - size.width * 0.06, badgeCenter.dy)
      ..lineTo(badgeCenter.dx - size.width * 0.015, badgeCenter.dy + size.width * 0.05)
      ..lineTo(badgeCenter.dx + size.width * 0.07, badgeCenter.dy - size.width * 0.06);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _paintTrust(Canvas canvas, Size size) {
    final structureStroke = Paint()
      ..color = structure
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shieldWidth = size.width * 0.42;
    final shieldTop = size.height * 0.18;
    final left = size.width / 2 - shieldWidth / 2;
    final right = size.width / 2 + shieldWidth / 2;
    final shieldPath = Path()
      ..moveTo(size.width / 2, shieldTop)
      ..lineTo(right, shieldTop + shieldWidth * 0.16)
      ..lineTo(right, shieldTop + shieldWidth * 0.58)
      ..lineTo(size.width / 2, shieldTop + shieldWidth * 1.1)
      ..lineTo(left, shieldTop + shieldWidth * 0.58)
      ..lineTo(left, shieldTop + shieldWidth * 0.16)
      ..close();
    canvas.drawPath(shieldPath, structureStroke);

    final starCenter = Offset(size.width / 2, shieldTop + shieldWidth * 0.52);
    canvas.drawPath(
      _starPath(starCenter, shieldWidth * 0.26, shieldWidth * 0.12),
      Paint()..color = _orange,
    );
  }

  Path _starPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 36 - 90) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.structure != structure;
}
