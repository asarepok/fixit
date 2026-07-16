// App-wide constant values: general app settings (AppConstants) and every
// navigable route path (AppRoutes).

class AppConstants {
  AppConstants._();

  static const String appName = "FixIt GH";
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double cardRadius = 16.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
}

// Every route path the app can navigate to. Used by app/router.dart to
// build the route table, and by screens when navigating, for example
// context.push(AppRoutes.profile) instead of context.push('/profile').
// When adding a new screen, add its path here first, then use it in both
// router.dart and wherever a screen needs to navigate to it.
class AppRoutes {
  AppRoutes._();

  static const splash = "/";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";
  static const home = "/home";
  static const search = "/search";
  static const booking = "/booking";
  static const bookingDetails = "/booking-details";
  static const chat = "/chat";
  static const notifications = "/notifications";
  static const profile = "/profile";
  static const editProfile = "/edit-profile";
  static const settings = "/settings";
  static const nearbyArtisans = "/nearby-artisans";
  static const artisanProfile = "/artisan-profile";
  static const artisanDashboard = "/artisan-dashboard";
  static const becomeArtisan = "/become-artisan";
  static const artisanApplication = "/artisan-application";
  static const artisanApplicationStatus = "/artisan-application-status";
  static const rateArtisan = "/rate-artisan";
  static const bookingDetail = "/booking-detail";
  static const paymentWaiting = "/payment-waiting";
  static const chatThread = "/chat-thread";
  static const map = "/map";
  static const adminDashboard = "/admin-dashboard";
  static const managePayments = "/manage-payments";
}
