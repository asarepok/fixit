import 'package:flutter/material.dart';


class AdminStatCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;


  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });


  @override
  Widget build(BuildContext context) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Row(

          children: [

            CircleAvatar(

              radius:25,

              child: Icon(icon),

            ),


            const SizedBox(width:15),


            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  value,

                  style: const TextStyle(

                    fontSize:22,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


                Text(title),

              ],

            )

          ],

        ),

      ),

    );

  }

}