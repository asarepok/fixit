import 'package:flutter/material.dart';


class SearchScreen extends StatelessWidget {

  const SearchScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text("Search Services"),

      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [


            TextField(

              decoration: InputDecoration(

                hintText: "Search artisan",

                prefixIcon:
                    const Icon(Icons.search),

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(12),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}