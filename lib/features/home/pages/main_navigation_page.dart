import 'package:flutter/material.dart';

import 'home_page.dart';
import '../../search/pages/search_page.dart';
import '../../booking/pages/booking_page.dart';
import '../../chat/pages/chat_page.dart';
import '../../profile/pages/profile_page.dart';


class MainNavigationPage extends StatefulWidget {

  const MainNavigationPage({super.key});


  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();

}


class _MainNavigationPageState 
    extends State<MainNavigationPage> {


  int currentIndex = 0;


  final pages = const [

    HomePage(),

    SearchPage(),

    BookingPage(),

    ChatPage(),

    ProfilePage(),

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