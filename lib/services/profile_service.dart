import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileService {


  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  final FirebaseAuth _auth =
      FirebaseAuth.instance;



  Future<DocumentSnapshot?> getCurrentUserProfile() async {


    User? user = _auth.currentUser;


    if(user == null){

      return null;

    }


    return await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

  }


}