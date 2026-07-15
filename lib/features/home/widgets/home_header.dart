import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Hello 👋",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            Text(
              "Find a service today",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

          ],

        ),


        CircleAvatar(

          radius: 25,

          backgroundColor:
              Theme.of(context)
                  .colorScheme
                  .primary,

          child: const Icon(
            Icons.notifications,
            color: Colors.white,
          ),

        ),

      ],

    );

  }
}