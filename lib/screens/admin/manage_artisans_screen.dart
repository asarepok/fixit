import 'package:flutter/material.dart';


class ManageArtisansScreen extends StatelessWidget {

  const ManageArtisansScreen({super.key});


  @override
  Widget build(BuildContext context) {


    final artisans = [

      "Electrical Masters",
      "Quick Plumbing GH",
      "Tech Repairs",

    ];


    return Scaffold(

      appBar: AppBar(

        title:
        const Text("Manage Artisans"),

      ),


      body: ListView.builder(

        padding:
        const EdgeInsets.all(20),

        itemCount: artisans.length,


        itemBuilder:(context,index){


          return Card(

            child: ListTile(

              leading:
              const CircleAvatar(

                child:
                Icon(Icons.handyman),

              ),


              title:
              Text(artisans[index]),


              subtitle:
              const Text(
                "Pending Verification",
              ),


              trailing: Row(

                mainAxisSize:
                MainAxisSize.min,


                children:[


                  IconButton(

                    icon:
                    const Icon(
                      Icons.check_circle,
                      color:Colors.green,
                    ),

                    onPressed:(){},

                  ),


                  IconButton(

                    icon:
                    const Icon(
                      Icons.cancel,
                      color:Colors.red,
                    ),

                    onPressed:(){},

                  ),

                ],

              ),

            ),

          );


        },

      ),

    );

  }

}