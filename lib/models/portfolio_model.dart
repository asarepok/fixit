// Mirrors a document in the "portfolio" collection: one of an artisan's
// "my work" photos on their public profile, see firestore.rules for who
// can add or remove one.
class PortfolioItem {
  final String id;
  final String artisanId;
  final String imageUrl;
  final DateTime? createdAt;

  const PortfolioItem({
    required this.id,
    required this.artisanId,
    required this.imageUrl,
    this.createdAt,
  });

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      id: map["id"] as String,
      artisanId: map["artisanId"] as String,
      imageUrl: map["imageUrl"] as String,
      createdAt: (map["createdAt"] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      "artisanId": artisanId,
      "imageUrl": imageUrl,
    };
  }
}
