import 'package:flutter/material.dart';


class ManageBookingsScreen extends StatelessWidget {

  const ManageBookingsScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title:
        const Text("Manage Bookings"),

      ),


      body: ListView(

        padding:
        const EdgeInsets.all(20),


        children:[


          Card(

            child: ListTile(

              leading:
              const Icon(Icons.calendar_month),


              title:
              const Text(
                "Electrical Repair",
              ),


              subtitle:
              const Text(
                "Status: Pending",
              ),


              trailing:
              DropdownButton<String>(

                value:"Pending",

                items:[

                  "Pending",
                  "Approved",
                  "Completed",
                  "Cancelled"

                ].map(

                    (e)=>DropdownMenuItem(

                    value:e,

                    child:Text(e),

                  )

                ).toList(),


                onChanged:(value){},


              ),

            ),

          ),


        ],

      ),

    );

  }

}