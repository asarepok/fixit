// The outcome of a "Become an Artisan" application, mirrors UserModel's
// artisanStatus values, minus "none", a VerificationRequest only exists
// once someone has actually applied.
enum VerificationStatus {
  pending,
  verified,
  rejected;

  String get value => name;

  static VerificationStatus fromValue(String? value) {
    return VerificationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

// Mirrors a document in the "verification_requests" collection, the
// application behind Become an Artisan. Reviewing one (approve/reject) is
// admin-only, see firestore.rules and VerificationRepository.
class VerificationRequest {
  final String id;
  final String artisanId;
  final String profession;
  final String bio;
  final String documentUrl;
  final VerificationStatus status;
  final String? reviewerNote;
  final DateTime? submittedAt;

  const VerificationRequest({
    required this.id,
    required this.artisanId,
    required this.profession,
    required this.bio,
    required this.documentUrl,
    required this.status,
    this.reviewerNote,
    this.submittedAt,
  });

  factory VerificationRequest.fromMap(Map<String, dynamic> map) {
    return VerificationRequest(
      id: map["id"] as String,
      artisanId: map["artisanId"] as String,
      profession: map["profession"] as String? ?? "",
      bio: map["bio"] as String? ?? "",
      documentUrl: map["documentUrl"] as String? ?? "",
      status: VerificationStatus.fromValue(map["status"] as String?),
      reviewerNote: map["reviewerNote"] as String?,
      submittedAt: (map["submittedAt"] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      "artisanId": artisanId,
      "profession": profession,
      "bio": bio,
      "documentUrl": documentUrl,
      "status": status.value,
    };
  }
}
