import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/location_service.dart';
import '../../../../services/database_service.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});


  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();

}



class _ProfilePageState extends State<ProfilePage> {

  final LocationService _locationService = LocationService();

final DatabaseService _databaseService = DatabaseService();

  final ProfileService _profileService =
      ProfileService();


  Map<String,dynamic>? userData;

  



  @override
  void initState(){

    super.initState();

    loadProfile();

  }
  Future<void> updateMyLocation() async {

  try {

    final position =
        await _locationService.getCurrentLocation();

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await _databaseService.updateUserLocation(

      uid,

      position.latitude,

      position.longitude,

    );

    if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Location updated successfully"),

        ),

      );

    }

  } catch (e) {

    if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(e.toString()),

        ),

      );

    }

  }

}



  Future<void> loadProfile() async {


    final snapshot =
        await _profileService
            .getCurrentUserProfile();


    if(snapshot != null &&
        snapshot.exists){


      setState(() {

        userData =
        snapshot.data()
        as Map<String,dynamic>;

      });


    }

  }




  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title:
        const Text("Profile"),

      ),




      body:

      userData == null

      ?

      const Center(
        child:CircularProgressIndicator(),
      )


      :

      Center(

        child:Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children:[


            const CircleAvatar(

              radius:50,

              child:Icon(

                Icons.person,

                size:50,

              ),

            ),




            const SizedBox(height:20),




            Text(

              userData!["name"] ?? "No name",

              style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall,

            ),




            const SizedBox(height:10),



            Text(
              userData!["email"] ?? "",
            ),




            const SizedBox(height:10),



            Text(
              userData!["phone"] ?? "",
            ),




            const SizedBox(height:10),




            Chip(

              label:Text(

                userData!["role"] ?? "user",

              ),

            ),





            const SizedBox(height:30),




            ElevatedButton.icon(

              icon:
              const Icon(Icons.edit),


              label:
              const Text(
                "Edit Profile",
              ),


              onPressed:() async {

  await context.push('/edit-profile');

  loadProfile();

},


            ),
            ElevatedButton.icon(

  icon: const Icon(Icons.settings),

  label: const Text("Settings"),

  onPressed: (){

    context.push('/settings');

  },

),
ElevatedButton.icon(

  icon: const Icon(Icons.location_on),

  label: const Text("Update My Location"),

  onPressed: updateMyLocation,

),



          ],


        ),

      ),


    );


  }


}