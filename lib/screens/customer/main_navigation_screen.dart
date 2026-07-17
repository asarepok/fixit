import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/badged_icon.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'bookings_screen.dart';
import '../chat/chat_screen.dart';
import 'profile_screen.dart';

// The bottom navigation shell for a signed-in customer: Home, Search,
// Bookings, Chat, and Profile as tabs. This is what AppRoutes.home opens.
// The artisan role has its own dashboard screen instead of this shell, see
// lib/screens/artisan/dashboard_screen.dart.
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
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
    // Bookings still in play (pending/accepted/in progress), not just a
    // raw count of everything ever booked, and every ticket-style thread
    // the customer's part of. Both are one-shot fetches, like the rest of
    // this app, so the badge only updates when the tab data is refetched,
    // not live.
    final bookings = ref.watch(myBookingsProvider).valueOrNull ?? const [];
    final activeBookings = bookings
        .where(
          (b) =>
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.accepted ||
              b.status == BookingStatus.inProgress,
        )
        .length;
    final chatCount = ref.watch(myChatsProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),

            selectedIcon: Icon(Icons.home),

            label: "Home",
          ),

          const NavigationDestination(
            icon: Icon(Icons.search),
            label: "Search",
          ),

          NavigationDestination(
            icon: BadgedIcon(
              icon: Icons.book_outlined,
              count: activeBookings,
            ),

            selectedIcon: BadgedIcon(icon: Icons.book, count: activeBookings),

            label: "Bookings",
          ),

          NavigationDestination(
            icon: BadgedIcon(icon: Icons.chat_outlined, count: chatCount),

            selectedIcon: BadgedIcon(icon: Icons.chat, count: chatCount),

            label: "Chat",
          ),

          const NavigationDestination(
            icon: Icon(Icons.person_outline),

            selectedIcon: Icon(Icons.person),

            label: "Profile",
          ),
        ],
      ),
    );
  }
}
