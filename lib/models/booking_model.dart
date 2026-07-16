import "payment_model.dart";

// Where a booking sits in the request -> work -> done lifecycle.
// declined and cancelled are both dead ends reachable only from pending,
// see BookingRepository for exactly who can move a booking between which
// states.
enum BookingStatus {
  pending,
  accepted,
  declined,
  inProgress,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return "pending";
      case BookingStatus.accepted:
        return "accepted";
      case BookingStatus.declined:
        return "declined";
      case BookingStatus.inProgress:
        return "in_progress";
      case BookingStatus.completed:
        return "completed";
      case BookingStatus.cancelled:
        return "cancelled";
    }
  }

  static BookingStatus fromValue(String? value) {
    return BookingStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

// Mirrors a document in the "bookings" collection. status and paymentStatus
// are separate fields, a booking can be accepted with payment still
// pending, amount and paymentStatus are both null until the artisan
// accepts with a quote and the customer pays.
class Booking {
  final String id;
  final String customerId;
  final String artisanId;
  final String description;
  final String location;
  final BookingStatus status;
  final double? amount;
  final PaymentStatus? paymentStatus;
  final String? paymentId;
  final String? chatId;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.artisanId,
    required this.description,
    required this.location,
    required this.status,
    this.amount,
    this.paymentStatus,
    this.paymentId,
    this.chatId,
    this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map["id"] as String,
      customerId: map["customerId"] as String,
      artisanId: map["artisanId"] as String,
      description: map["description"] as String? ?? "",
      location: map["location"] as String? ?? "",
      status: BookingStatus.fromValue(map["status"] as String?),
      amount: (map["amount"] as num?)?.toDouble(),
      paymentStatus: map["paymentStatus"] == null
          ? null
          : PaymentStatus.fromValue(map["paymentStatus"] as String?),
      paymentId: map["paymentId"] as String?,
      chatId: map["chatId"] as String?,
      createdAt: (map["createdAt"] as dynamic)?.toDate(),
    );
  }

  // Used when creating a new booking, deliberately narrow, a fresh booking
  // only ever has these fields, everything else (amount, paymentStatus,
  // paymentId) gets added later by the repository methods that set them.
  Map<String, dynamic> toCreateMap() {
    return {
      "customerId": customerId,
      "artisanId": artisanId,
      "description": description,
      "location": location,
      "status": status.value,
      "chatId": chatId,
    };
  }
}
