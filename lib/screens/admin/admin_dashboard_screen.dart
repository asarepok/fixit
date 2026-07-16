import 'package:flutter/material.dart';

import 'widgets/admin_stat_card.dart';
import 'widgets/admin_menu_tile.dart';
import 'manage_users_screen.dart';
import 'manage_artisans_screen.dart';
import 'manage_bookings_screen.dart';
import 'widgets/analytics_card.dart';

class AdminDashboardScreen extends StatelessWidget {

  const AdminDashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title:
        const Text("Admin Dashboard"),

      ),


      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [


            Text(

              "Overview",

              style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall,

            ),
           Row(
  children: [

    const AnalyticsCard(
      title:"Revenue",
      value:"GH₵15k",
      icon:Icons.money,
    ),

    const SizedBox(width:10),

    const AnalyticsCard(
      title:"Growth",
      value:"24%",
      icon:Icons.trending_up,
    ),

  ],
),


            const SizedBox(height:20),


            const AdminStatCard(

              title:"Total Users",

              value:"1,250",

              icon:Icons.people,

            ),


            const AdminStatCard(

              title:"Artisans",

              value:"350",

              icon:Icons.handyman,

            ),


            const AdminStatCard(

              title:"Bookings",

              value:"890",

              icon:Icons.book_online,

            ),


            const SizedBox(height:30),


            Text(

              "Management",

              style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall,

            ),


            const SizedBox(height:15),


            AdminMenuTile(

              title:"Manage Users",

              icon:Icons.people,

              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ManageUsersScreen(),
    ),
  );
},
            ),


            AdminMenuTile(

              title:"Manage Artisans",

              icon:Icons.build,

              onTap:(){

   Navigator.push(
     context,
     MaterialPageRoute(
       builder:(context)=>const ManageArtisansScreen(),
     ),
   );

 },

            ),


            AdminMenuTile(

              title:"Manage Bookings",

              icon:Icons.calendar_month,

             onTap:(){

   Navigator.push(
     context,
     MaterialPageRoute(
       builder:(context)=>const ManageBookingsScreen(),
     ),
   );

 },
            ),


          ],

        ),

      ),

    );

  }

}