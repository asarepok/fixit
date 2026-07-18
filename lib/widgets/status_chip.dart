import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/payment_model.dart';

// The six-color status language used everywhere a booking or payment shows
// its state: amber (not started), blue (accepted/secured), purple (active
// work), green (done), red (declined/failed), grey (cancelled/refunded).
// Booking and payment status intentionally share this palette, amber ->
// blue -> green reads the same way for both, see StatusChip.booking and
// StatusChip.payment.
enum StatusTone { pending, accepted, progress, completed, declined, cancelled }

class _ToneColors {
  const _ToneColors(this.fg, this.bg);
  final Color fg;
  final Color bg;
}

const _lightTones = {
  StatusTone.pending: _ToneColors(Color(0xFFC47F0A), Color(0xFFFDF1DC)),
  StatusTone.accepted: _ToneColors(Color(0xFF1565C0), Color(0xFFE3EDFA)),
  StatusTone.progress: _ToneColors(Color(0xFF6A3FC9), Color(0xFFEDE5FB)),
  StatusTone.completed: _ToneColors(Color(0xFF2E7D32), Color(0xFFE3F1E4)),
  StatusTone.declined: _ToneColors(Color(0xFFC22A2A), Color(0xFFFBE6E6)),
  StatusTone.cancelled: _ToneColors(Color(0xFF6B7480), Color(0xFFEAECEF)),
};

const _darkTones = {
  StatusTone.pending: _ToneColors(Color(0xFFE0A94A), Color(0xFF3A2F18)),
  StatusTone.accepted: _ToneColors(Color(0xFF6BA6EE), Color(0xFF1C2C40)),
  StatusTone.progress: _ToneColors(Color(0xFFA586EF), Color(0xFF2A2140)),
  StatusTone.completed: _ToneColors(Color(0xFF6FC478), Color(0xFF1C3220)),
  StatusTone.declined: _ToneColors(Color(0xFFE2716F), Color(0xFF3A1F1F)),
  StatusTone.cancelled: _ToneColors(Color(0xFF9AA3AD), Color(0xFF24272B)),
};

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  factory StatusChip.booking(BookingStatus status) {
    final (tone, label) = switch (status) {
      BookingStatus.pending => (StatusTone.pending, 'Pending'),
      BookingStatus.accepted => (StatusTone.accepted, 'Accepted'),
      BookingStatus.inProgress => (StatusTone.progress, 'In Progress'),
      BookingStatus.completed => (StatusTone.completed, 'Completed'),
      BookingStatus.declined => (StatusTone.declined, 'Declined'),
      BookingStatus.cancelled => (StatusTone.cancelled, 'Cancelled'),
    };
    return StatusChip(label: label, tone: tone);
  }

  factory StatusChip.payment(PaymentStatus status) {
    final (tone, label) = switch (status) {
      PaymentStatus.pending => (StatusTone.pending, 'Payment Pending'),
      PaymentStatus.heldInEscrow => (StatusTone.accepted, 'Payment Secured'),
      PaymentStatus.releasing => (StatusTone.accepted, 'Sending Payment'),
      PaymentStatus.released => (StatusTone.completed, 'Paid'),
      PaymentStatus.refunded => (StatusTone.cancelled, 'Refunded'),
      PaymentStatus.failed => (StatusTone.declined, 'Payment Failed'),
    };
    return StatusChip(label: label, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = (dark ? _darkTones : _lightTones)[tone]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: colors.fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.fg,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
