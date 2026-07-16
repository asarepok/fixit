import 'package:flutter/material.dart';


class BookingPage extends StatelessWidget {

  const BookingPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("My Bookings"),

      ),


      body: const Center(

        child: Text(

          "No bookings yet",

          style: TextStyle(fontSize:18),

        ),

      ),

    );

  }

}