import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class EditProfilePage extends StatefulWidget {

  const EditProfilePage({super.key});


  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();

}




class _EditProfilePageState 
extends State<EditProfilePage>{


final nameController =
TextEditingController();


final phoneController =
TextEditingController();



final ProfileService profileService =
ProfileService();



Future<void> updateProfile() async {


final uid =
FirebaseAuth.instance.currentUser!.uid;



await FirebaseFirestore.instance
.collection("users")
.doc(uid)
.update({

"name":
nameController.text.trim(),


"phone":
phoneController.text.trim(),

});



if(mounted){

Navigator.pop(context, true);

}


}



@override
Widget build(BuildContext context){


return Scaffold(


appBar:AppBar(

title:
const Text(
"Edit Profile",
),

),


body:Padding(

padding:
const EdgeInsets.all(20),


child:Column(

children:[


TextField(

controller:nameController,

decoration:
const InputDecoration(

labelText:"Name",

),

),



const SizedBox(height:20),



TextField(

controller:phoneController,

keyboardType:
TextInputType.phone,


decoration:
const InputDecoration(

labelText:"Phone",

),

),



const SizedBox(height:30),



ElevatedButton(

onPressed:updateProfile,


child:
const Text(
"Save Changes",
),

),


],


),


),


);


}


}