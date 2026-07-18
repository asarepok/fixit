// Represents a user document stored in the Firestore "users" collection.
// Every account is a customer by default, role only ever distinguishes a
// plain account ("user") from an admin ("admin"), admin accounts are
// provisioned outside the app, never self-serve.
//
// Being an artisan is an added capability, not a separate role: artisanStatus
// tracks the Become an Artisan application ("none", "pending", "verified",
// "rejected"), profession/bio/averageRating/ratingCount only mean something
// once artisanStatus is "verified". latitude/longitude are optional since a
// user may not have shared their location yet. momoNetwork (MTN, Vodafone,
// AirtelTigo) is only needed for an artisan, a future cashout flow will
// use it alongside phone to register a Paystack payout recipient. balance
// is an artisan's running total from released payments, only ever changed
// by releaseEscrowToArtisan (and eventually a cashout function) through
// the Admin SDK, never directly writable by the client, see
// firestore.rules. fcmToken is this device's push token, set by
// NotificationService on login/token refresh, used server-side by the
// Cloud Functions in functions/src/notifications to address a push at
// this user. notificationsEnabled is the user's own on/off preference,
// defaults true; turning it off also clears fcmToken (see
// AuthRepository.setNotificationsEnabled), so muting happens server-side
// for free, a Cloud Function with no token to send to just skips it.
class UserModel {

  final String uid;

  final String name;

  final String email;

  final String role;

  final String phone;

  final double? latitude;

  final double? longitude;

  // A human-readable label for latitude/longitude ("Tesano, Accra"),
  // resolved once by LocationPickerScreen at the moment the location is
  // set, not re-resolved on every screen that wants to show it, see
  // AuthRepository.updateMyLocation.
  final String? locationLabel;

  final String artisanStatus;

  final String? profession;

  final String? bio;

  final double? averageRating;

  final int? ratingCount;

  final String? momoNetwork;

  final double balance;

  final String? fcmToken;

  final bool notificationsEnabled;



  UserModel({

    required this.uid,

    required this.name,

    required this.email,

    required this.role,

    required this.phone,

    this.latitude,

    this.longitude,

    this.locationLabel,

    this.artisanStatus = "none",

    this.profession,

    this.bio,

    this.averageRating,

    this.ratingCount,

    this.momoNetwork,

    this.balance = 0,

    this.fcmToken,

    this.notificationsEnabled = true,

  });



  // Use these to check a user's capabilities, for example to decide which
  // screen to navigate to, or to gate an admin-only widget like AdminGuard.
  bool get isAdmin => role == "admin";

  bool get isArtisan => artisanStatus == "verified";

  bool get hasPendingArtisanApplication => artisanStatus == "pending";



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

      locationLabel: map["locationLabel"] as String?,

      artisanStatus: map["artisanStatus"] as String? ?? "none",

      profession: map["profession"] as String?,

      bio: map["bio"] as String?,

      averageRating: (map["averageRating"] as num?)?.toDouble(),

      ratingCount: (map["ratingCount"] as num?)?.toInt(),

      momoNetwork: map["momoNetwork"] as String?,

      balance: (map["balance"] as num?)?.toDouble() ?? 0,

      fcmToken: map["fcmToken"] as String?,

      notificationsEnabled: map["notificationsEnabled"] as bool? ?? true,

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

      "artisanStatus":artisanStatus,

      "profession":profession,

      "bio":bio,

      "averageRating":averageRating,

      "ratingCount":ratingCount,

      "momoNetwork":momoNetwork,

    };

  }


}
