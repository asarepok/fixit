import 'package:flutter/material.dart';


class ServiceCategoryCard extends StatelessWidget {

  final IconData icon;
  final String title;


  const ServiceCategoryCard({

    super.key,

    required this.icon,

    required this.title,

  });


  @override
  Widget build(BuildContext context) {

    return Container(

      width: 100,

      padding: const EdgeInsets.all(12),


      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: const [

          BoxShadow(

            blurRadius: 5,

            color: Colors.black12,

          )

        ],

      ),


      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(

            icon,

            size: 35,

            color:
                Theme.of(context)
                    .colorScheme
                    .primary,

          ),


          const SizedBox(height:10),


          Text(

            title,

            textAlign:
                TextAlign.center,

          ),

        ],

      ),

    );

  }

}