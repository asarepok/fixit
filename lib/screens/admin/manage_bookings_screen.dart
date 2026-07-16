import 'package:flutter/material.dart';
import 'manage_artisans_screen.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdminEmptyScreen(
    title: 'Manage Bookings',
    icon: Icons.calendar_month_outlined,
    message:
        'Bookings will appear here once the booking provider is available.',
  );
}
