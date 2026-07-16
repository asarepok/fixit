// Mirrors a document in the "reviews" collection. Only ever created for a
// booking that is the reviewer's own and already completed, see
// firestore.rules and ReviewRepository.submitReview for exactly how that's
// enforced.
class Review {
  final String id;
  final String bookingId;
  final String customerId;
  final String artisanId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.artisanId,
    required this.rating,
    this.comment = "",
    this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map["id"] as String,
      bookingId: map["bookingId"] as String,
      customerId: map["customerId"] as String,
      artisanId: map["artisanId"] as String,
      rating: (map["rating"] as num).toInt(),
      comment: map["comment"] as String? ?? "",
      createdAt: (map["createdAt"] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      "bookingId": bookingId,
      "customerId": customerId,
      "artisanId": artisanId,
      "rating": rating,
      "comment": comment,
    };
  }
}
