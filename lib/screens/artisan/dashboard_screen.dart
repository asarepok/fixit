import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArtisanDashboardScreen extends StatelessWidget {

  const ArtisanDashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Artisan Dashboard"),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Welcome Artisan",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height:30),


            

            Card(
  child: ListTile(

    leading: const Icon(Icons.person),

    title: const Text(
      "My Profile",
    ),

    subtitle: const Text(
      "View and edit your information",
    ),


    onTap: (){

      context.push('/profile');

    },

  ),
),


            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text("Bookings"),
                subtitle: const Text(
                  "View customer requests",
                ),
              ),
            ),


            Card(
              child: ListTile(
                leading: const Icon(Icons.money),
                title: const Text("Earnings"),
                subtitle: const Text(
                  "Track your income",
                ),
              ),
            ),


          ],

        ),

      ),

    );

  }

}