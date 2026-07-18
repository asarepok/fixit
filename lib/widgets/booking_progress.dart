import 'package:flutter/material.dart';

import '../models/booking_model.dart';

// A connected-dot progress track for the four statuses a booking moves
// through on its way to done. declined/cancelled are dead ends off this
// line entirely, not a fifth step, callers should show StatusChip instead
// for those two, see BookingDetailScreen.
//
// Every step is an Expanded slice of equal width, with its connecting
// line built from the two halves either side of its own dot, rather than
// lines as separate flex children between intrinsically-sized labels.
// That's what keeps the whole track evenly spaced regardless of how long
// each label is, instead of drifting off-center.
class BookingProgress extends StatelessWidget {
  const BookingProgress({super.key, required this.status});

  final BookingStatus status;

  static const _steps = [
    (BookingStatus.pending, 'Requested'),
    (BookingStatus.accepted, 'Confirmed'),
    (BookingStatus.inProgress, 'In Progress'),
    (BookingStatus.completed, 'Done'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = _steps.indexWhere((s) => s.$1 == status);
    final bodyColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: i == 0
                          ? const SizedBox(height: 2)
                          : Container(
                              height: 2,
                              color: i <= currentIndex
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= currentIndex
                            ? colorScheme.primary
                            : Theme.of(context).cardTheme.color,
                        border: Border.all(
                          color: i <= currentIndex
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: i == _steps.length - 1
                          ? const SizedBox(height: 2)
                          : Container(
                              height: 2,
                              color: i < currentIndex
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _steps[i].$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: i <= currentIndex ? FontWeight.w700 : FontWeight.w500,
                    color: i <= currentIndex ? bodyColor : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
