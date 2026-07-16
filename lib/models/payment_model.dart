// Where a booking's money is in the MoMo escrow flow. Separate from
// BookingStatus on purpose, a booking can be "accepted" with payment still
// "pending", they're two different fields tracking two different things.
enum PaymentStatus {
  pending,
  heldInEscrow,
  releasing,
  released,
  refunded,
  failed;

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return "pending";
      case PaymentStatus.heldInEscrow:
        return "held_in_escrow";
      case PaymentStatus.releasing:
        return "releasing";
      case PaymentStatus.released:
        return "released";
      case PaymentStatus.refunded:
        return "refunded";
      case PaymentStatus.failed:
        return "failed";
    }
  }

  static PaymentStatus fromValue(String? value) {
    return PaymentStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

// A record of one booking's payment, mirrors a document in the "payments"
// collection. Only ever written by the Cloud Functions in functions/src,
// this model is read-only from the app's side.
class Payment {
  final String id;
  final String bookingId;
  final String customerId;
  final String artisanId;
  final double amount;
  final PaymentStatus status;
  final String? momoReferenceId;
  final String? momoDisbursementReferenceId;
  final String? refundReason;
  final DateTime? createdAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.artisanId,
    required this.amount,
    required this.status,
    this.momoReferenceId,
    this.momoDisbursementReferenceId,
    this.refundReason,
    this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map["id"] as String,
      bookingId: map["bookingId"] as String,
      customerId: map["customerId"] as String,
      artisanId: map["artisanId"] as String,
      amount: (map["amount"] as num).toDouble(),
      status: PaymentStatus.fromValue(map["status"] as String?),
      momoReferenceId: map["momoReferenceId"] as String?,
      momoDisbursementReferenceId: map["momoDisbursementReferenceId"] as String?,
      refundReason: map["refundReason"] as String?,
      createdAt: (map["createdAt"] as dynamic)?.toDate(),
    );
  }
}
