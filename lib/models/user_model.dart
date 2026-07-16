// Represents a user document stored in the Firestore "users" collection.
// Covers customers, artisans, and admins, the role field tells them apart.
// latitude/longitude are optional since a user may not have shared their
// location yet.
class UserModel {

  final String uid;

  final String name;

  final String email;

  final String role;

  final String phone;

  final double? latitude;

  final double? longitude;



  UserModel({

    required this.uid,

    required this.name,

    required this.email,

    required this.role,

    required this.phone,

    this.latitude,

    this.longitude,

  });



  // Use these to check a user's role, for example to decide which screen to
  // navigate to, or to gate an admin-only widget like AdminGuard.
  bool get isAdmin => role == "admin";

  bool get isArtisan => role == "artisan";



  // Builds a UserModel from a Firestore document's data. Use this any time
  // user data is read from Firestore, rather than reading fields off the
  // raw Map by hand.
  factory UserModel.fromMap(Map<String, dynamic> map) {

    return UserModel(

      uid: map["uid"] as String,

      name: map["name"] as String? ?? "",

      email: map["email"] as String? ?? "",

      role: map["role"] as String? ?? "user",

      phone: map["phone"] as String? ?? "",

      latitude: (map["latitude"] as num?)?.toDouble(),

      longitude: (map["longitude"] as num?)?.toDouble(),

    );

  }



  // Converts this model back into a plain Map for saving to Firestore.
  Map<String,dynamic> toMap(){

    return {

      "uid":uid,

      "name":name,

      "email":email,

      "role":role,

      "phone":phone,

      "latitude":latitude,

      "longitude":longitude,

    };

  }


}