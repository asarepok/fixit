import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/primary_button.dart';


class ArtisanProfileScreen extends StatelessWidget {

  const ArtisanProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Artisan Profile",
        ),

      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [


            const Center(

              child: CircleAvatar(

                radius:55,

                child: Icon(

                  Icons.person,

                  size:60,

                ),

              ),

            ),


            const SizedBox(height:20),


            Center(

              child: Text(

                "Kwame Electricals",

                style:
                Theme.of(context)
                    .textTheme
                    .headlineSmall,

              ),

            ),


            const SizedBox(height:5),


            const Center(

              child: Text(

                "Certified Electrician",

              ),

            ),


            const SizedBox(height:30),


            const Text(

              "About",

              style: TextStyle(

                fontSize:20,

                fontWeight:FontWeight.bold,

              ),

            ),


            const SizedBox(height:10),


            const Text(

              "Experienced electrician providing reliable home electrical repairs and installations.",

            ),


            const Spacer(),


            PrimaryButton(

              text:"Book Service",

              onPressed:(){

                context.push('/booking-details');

              },

            )

          ],

        ),

      ),

    );

  }

}