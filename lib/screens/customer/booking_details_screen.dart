import 'package:flutter/material.dart';


import '../../widgets/primary_button.dart';


class BookingDetailsScreen extends StatelessWidget {

  const BookingDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title:
        const Text("Book Service"),

      ),


      body: Padding(

        padding:
        const EdgeInsets.all(20),


        child: Column(

          children: [


            const TextField(

              decoration:
              InputDecoration(

                labelText:
                "Describe your problem",

                prefixIcon:
                Icon(Icons.description),

              ),

              maxLines:3,

            ),


            const SizedBox(height:20),


            const TextField(

              decoration:
              InputDecoration(

                labelText:
                "Location",

                prefixIcon:
                Icon(Icons.location_on),

              ),

            ),


            const SizedBox(height:30),


            PrimaryButton(

              text:"Confirm Booking",

              onPressed:(){},

            )

          ],

        ),

      ),

    );

  }

}