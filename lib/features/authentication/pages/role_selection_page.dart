import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/database_service.dart';


class RoleSelectionPage extends StatelessWidget {

  const RoleSelectionPage({super.key});


  Future<void> selectRole(
      BuildContext context,
      String role,
      ) async {


    final user = FirebaseAuth.instance.currentUser;


    if(user == null) return;


    await DatabaseService().updateUserRole(
      user.uid,
      role,
    );


    if(context.mounted){

      context.go('/home');

    }


  }





  Widget buildCard(
      BuildContext context,
      IconData icon,
      String title,
      String role,
      String subtitle,
      ) {


    return Card(

      child: ListTile(

        leading:
        Icon(icon, size:40),


        title:
        Text(title),


        subtitle:
        Text(subtitle),


        trailing:
        const Icon(Icons.arrow_forward_ios),



        onTap: (){

          selectRole(
            context,
            role,
          );

        },

      ),

    );


  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar:
      AppBar(

        title:
        const Text("Choose Your Role"),

      ),



      body:
      Padding(

        padding:
        const EdgeInsets.all(20),



        child:
        Column(

          children:[



            buildCard(

              context,

              Icons.person,

              "Customer",

              "customer",

              "Hire skilled artisans",

            ),




            const SizedBox(height:20),





            buildCard(

              context,

              Icons.handyman,

              "Artisan",

              "artisan",

              "Provide services and earn",

            ),



          ],

        ),

      ),

    );

  }


}