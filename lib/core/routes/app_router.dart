import 'package:go_router/go_router.dart';

import '../../features/authentication/pages/splash_page.dart';
import '../../features/authentication/pages/onboarding_page.dart';
import '../../features/authentication/pages/login_page.dart';
import '../../features/authentication/pages/register_page.dart';
import '../../features/authentication/pages/forgot_password_page.dart';
import '../../features/authentication/pages/role_selection_page.dart';
import '../../features/home/pages/main_navigation_page.dart';
import '../../features/booking/pages/artisan_profile_page.dart';
import '../../features/booking/pages/booking_detail_page.dart';
import '../../features/artisan/pages/artisan_dashboard_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/admin/pages/admin_dashboard_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/search/pages/nearby_artisans_page.dart';
import '../../features/maps/pages/map_page.dart';

final GoRouter appRouter = GoRouter(

  initialLocation: '/',

  routes: [

    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    GoRoute(
 path:'/profile',
 builder:(context,state)=>const ProfilePage(),
),

    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionPage(),
    ),
  GoRoute(
 path:'/artisan-profile',
 builder:(context,state)=>const ArtisanProfilePage(),
),
GoRoute(
 path: '/artisan-dashboard',
 builder:(context,state)=>const ArtisanDashboardPage(),
),
GoRoute(
  path: '/admin-dashboard',
  builder: (context, state) =>
      const AdminDashboardPage(),
),
GoRoute(
  path: '/settings',
  builder: (context, state) =>
      const SettingsPage(),
),
GoRoute(
 path:'/nearby-artisans',
 builder:(context,state)=>
 const NearbyArtisansPage(),
),
GoRoute(
path:'/map',
builder:(context,state)=>
const MapPage(),
),


GoRoute(
 path:'/booking-details',
 builder:(context,state)=>const BookingDetailsPage(),
),

  GoRoute(
  path: '/home',
  builder: (context, state) => const MainNavigationPage(),
),
GoRoute(

path:'/edit-profile',

builder:(context,state)=>
const EditProfilePage(),

),

  ],

);