import 'package:flutter/material.dart';
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
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionPage(),
    ),
  GoRoute(
 path:'/artisan-profile',
 builder:(context,state)=>const ArtisanProfilePage(),
),


GoRoute(
 path:'/booking-details',
 builder:(context,state)=>const BookingDetailsPage(),
),

  GoRoute(
  path: '/home',
  builder: (context, state) => const MainNavigationPage(),
),

  ],

);