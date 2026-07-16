import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'bookings_screen.dart';
import '../chat/chat_screen.dart';
import 'profile_screen.dart';

// The bottom navigation shell for a signed-in customer: Home, Search,
// Bookings, Chat, and Profile as tabs. This is what AppRoutes.home opens.
// The artisan role has its own dashboard screen instead of this shell, see
// lib/screens/artisan/dashboard_screen.dart.
class MainNavigationScreen extends StatefulWidget {

  const MainNavigationScreen({super.key});


  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();

}


class _MainNavigationScreenState
    extends State<MainNavigationScreen> {


  int currentIndex = 0;


  final pages = const [

    HomeScreen(),

    SearchScreen(),

    BookingsScreen(),

    ChatScreen(),

    ProfileScreen(),

  ];


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: pages[currentIndex],


      bottomNavigationBar: NavigationBar(

        selectedIndex: currentIndex,


        onDestinationSelected: (index){

          setState(() {

            currentIndex = index;

          });

        },


        destinations: const [

          NavigationDestination(

            icon: Icon(Icons.home_outlined),

            selectedIcon: Icon(Icons.home),

            label: "Home",

          ),


          NavigationDestination(

            icon: Icon(Icons.search),

            label: "Search",

          ),


          NavigationDestination(

            icon: Icon(Icons.book_outlined),

            selectedIcon: Icon(Icons.book),

            label: "Bookings",

          ),


          NavigationDestination(

            icon: Icon(Icons.chat_outlined),

            selectedIcon: Icon(Icons.chat),

            label: "Chat",

          ),


          NavigationDestination(

            icon: Icon(Icons.person_outline),

            selectedIcon: Icon(Icons.person),

            label: "Profile",

          ),

        ],

      ),

    );

  }

}