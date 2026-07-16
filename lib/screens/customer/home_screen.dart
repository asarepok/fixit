import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../widgets/home_header.dart';
import '../../widgets/service_category_card.dart';
import '../../widgets/artisan_card.dart';


class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const HomeHeader(),


              const SizedBox(height:25),


              TextField(

                decoration: InputDecoration(

                  hintText:
                      "Search artisans or services",

                  prefixIcon:
                      const Icon(Icons.search),

                  filled:true,

                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(15),

                    borderSide:
                        BorderSide.none,

                  ),

                ),

              ),


              const SizedBox(height:20),


              ElevatedButton(

                onPressed: (){

                  context.push(AppRoutes.nearbyArtisans);

                },

                child: const Text(
                  "Find Nearby Artisans",
                ),

              ),



              const SizedBox(height:30),


              Text(

                "Services",

                style:
                    Theme.of(context)
                        .textTheme
                        .headlineSmall,

              ),


              const SizedBox(height:15),


              SizedBox(

                height:120,

                child: ListView(

                  scrollDirection:
                      Axis.horizontal,


                  children: const [

                    ServiceCategoryCard(

                      icon: Icons.electrical_services,

                      title:"Electrician",

                    ),


                    SizedBox(width:15),


                    ServiceCategoryCard(

                      icon: Icons.plumbing,

                      title:"Plumber",

                    ),


                    SizedBox(width:15),


                    ServiceCategoryCard(

                      icon: Icons.build,

                      title:"Mechanic",

                    ),


                    SizedBox(width:15),


                    ServiceCategoryCard(

                      icon: Icons.cleaning_services,

                      title:"Cleaner",

                    ),

                  ],

                ),

              ),


              const SizedBox(height:30),


              Text(

                "Featured Artisans",

                style:
                    Theme.of(context)
                        .textTheme
                        .headlineSmall,

              ),


              const SizedBox(height:15),


              const ArtisanCard(

                name:"Kwame Electricals",

                profession:"Certified Electrician",

              ),


              const ArtisanCard(

                name:"Ama Plumbing Services",

                profession:"Professional Plumber",

              ),


              const ArtisanCard(

                name:"Kojo Repairs",

                profession:"Home Appliance Repair",

              ),


            ],

          ),

        ),

      ),

    );

  }

}