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
import '../screens/customer/main_navigation_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/artisan_profile_screen.dart';
import '../screens/customer/booking_details_screen.dart';
import '../screens/customer/booking_detail_screen.dart';
import '../screens/customer/payment_waiting_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/edit_profile_screen.dart';
import '../screens/customer/rate_artisan_screen.dart';
import '../screens/customer/nearby_artisans_screen.dart';
import '../screens/artisan/dashboard_screen.dart';
import '../screens/artisan/manage_portfolio_screen.dart';
import '../screens/onboarding/artisan_application_screen.dart';
import '../screens/onboarding/artisan_application_status_screen.dart';
import '../screens/onboarding/become_artisan_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_payments_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/location_picker_screen.dart';
import '../screens/maps/map_screen.dart';
import '../screens/chat/chat_thread_screen.dart';
import '../models/user_model.dart';

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
      path: AppRoutes.artisanProfile,
      builder: (context, state) =>
          ArtisanProfileScreen(artisan: state.extra as UserModel?),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) =>
          SearchScreen(initialQuery: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.artisanDashboard,
      builder: (context, state) => const ArtisanDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.becomeArtisan,
      builder: (context, state) => const BecomeArtisanScreen(),
    ),
    GoRoute(
      path: AppRoutes.artisanApplication,
      builder: (context, state) => const ArtisanApplicationScreen(),
    ),
    GoRoute(
      path: AppRoutes.artisanApplicationStatus,
      builder: (context, state) => const ArtisanApplicationStatusScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.managePayments,
      builder: (context, state) => const ManagePaymentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.locationPicker,
      builder: (context, state) => const LocationPickerScreen(),
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
      path: AppRoutes.managePortfolio,
      builder: (context, state) => const ManagePortfolioScreen(),
    ),
    GoRoute(
      path: AppRoutes.bookingDetails,
      builder: (context, state) =>
          BookingDetailsScreen(artisan: state.extra as UserModel?),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.rateArtisan,
      builder: (context, state) =>
          RateArtisanScreen(args: state.extra as RateArtisanArgs),
    ),
    GoRoute(
      path: AppRoutes.bookingDetail,
      builder: (context, state) =>
          BookingDetailScreen(bookingId: state.extra as String),
    ),
    GoRoute(
      path: AppRoutes.paymentWaiting,
      builder: (context, state) =>
          PaymentWaitingScreen(args: state.extra as PaymentWaitArgs),
    ),
    GoRoute(
      path: AppRoutes.chatThread,
      builder: (context, state) =>
          ChatThreadScreen(chatId: state.extra as String),
    ),
  ],
);
