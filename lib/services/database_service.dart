import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';



class DatabaseService {


final FirebaseFirestore _firestore =
    FirebaseFirestore.instance;



Future<void> createUser(
    UserModel user
    ) async {


 await _firestore
     .collection("users")
     .doc(user.uid)
     .set(
       user.toMap()
     );



}

Future<void> updateUserLocation(
  String uid,
  double latitude,
  double longitude,
) async {

  await _firestore
      .collection("users")
      .doc(uid)
      .update({

    "latitude": latitude,

    "longitude": longitude,

  });

}

Future<void> updateUserRole(
    String uid,
    String role,
) async {

  await _firestore
      .collection("users")
      .doc(uid)
      .update({

    "role": role,

  });

}

Future<List<Map<String,dynamic>>> getArtisans() async {


  final snapshot =
      await _firestore
      .collection("users")
      .where(
        "role",
        isEqualTo: "artisan",
      )
      .get();



  return snapshot.docs
      .map(
        (doc)=>doc.data(),
      )
      .toList();


}

Future<String?> getUserRole(String uid) async {

  DocumentSnapshot doc =
      await _firestore
          .collection("users")
          .doc(uid)
          .get();


  if(doc.exists){

    return doc["role"];

  }

  return null;

}
}