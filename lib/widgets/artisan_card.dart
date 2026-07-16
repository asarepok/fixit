import 'package:flutter/material.dart';


class ArtisanCard extends StatelessWidget {

  final String name;
  final String profession;


  const ArtisanCard({

    super.key,

    required this.name,

    required this.profession,

  });


  @override
  Widget build(BuildContext context) {

    return Card(

      child: ListTile(

        leading: CircleAvatar(

          backgroundColor:
              Theme.of(context)
                  .colorScheme
                  .primary,

          child: const Icon(

            Icons.person,

            color: Colors.white,

          ),

        ),


        title: Text(name),


        subtitle: Text(profession),


        trailing: const Icon(
          Icons.star,
          color: Colors.orange,
        ),

      ),

    );

  }

}