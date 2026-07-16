import 'package:go_router/go_router.dart';

// This is the app's full navigation table. Every screen the app can
// navigate to needs a GoRoute entry here. Use the path constants from
// AppRoutes (constants.dart) for the path, not a hardcoded string, so a
// typo in a path shows up as a compile error.
import 'constants.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/customer/main_navigation_screen.dart';
import '../screens/customer/artisan_profile_screen.dart';
import '../screens/customer/booking_details_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/edit_profile_screen.dart';
import '../screens/customer/nearby_artisans_screen.dart';
import '../screens/artisan/dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/maps/map_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.artisanProfile,
      builder: (context, state) => const ArtisanProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.artisanDashboard,
      builder: (context, state) => const ArtisanDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.nearbyArtisans,
      builder: (context, state) => const NearbyArtisansScreen(),
    ),
    GoRoute(
      path: AppRoutes.map,
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: AppRoutes.bookingDetails,
      builder: (context, state) => const BookingDetailsScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
);
