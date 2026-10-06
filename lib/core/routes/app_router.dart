import 'package:go_router/go_router.dart';

import '../localization/app_settings.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/language_selection_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/driver/presentation/driver_dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_products_screen.dart';
import '../../features/farmer/presentation/add_edit_product_screen.dart';
import '../../features/cart/presentation/checkout_delivery_screen.dart';
import '../../features/orders_chat/presentation/orders_chat_screen.dart';
import '../../features/auth/presentation/buyer_registration_screen.dart';
import '../../features/auth/presentation/farmer_registration_screen.dart';
import '../../features/auth/presentation/driver_registration_screen.dart';
import '../../features/buyer/buyer.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract final class AppRoutes {
  static const String splash          = '/';
  static const String language        = '/language';
  static const String welcome         = '/welcome';
  static const String onboarding      = '/onboarding';
  static const String roleSelection   = '/role';
  static const String phoneAuth       = '/phone-auth';
  static const String login           = '/login';
  static const String buyerRegister   = '/register-buyer';
  static const String farmerRegister  = '/register-farmer';
  static const String driverRegister  = '/register-driver';
  static const String dashboard       = '/dashboard';
  static const String farmerDashboard = '/farmer-dashboard';
  static const String driverDashboard = '/driver-dashboard';
  static const String farmerProducts  = '/farmer-products';
  static const String addEditProduct  = '/add-edit-product';
  static const String searchFilter    = '/search-filter';
  static const String ordersChat      = '/orders-chat';
  static const String cart            = '/cart';
  static const String checkout        = '/checkout';

  /// Role-based home dashboard.
  static String homeFor(UserRole role) => switch (role) {
        UserRole.buyer  => dashboard,
        UserRole.farmer => farmerDashboard,
        UserRole.driver => driverDashboard,
      };

  /// Role-based registration screen.
  static String registerFor(UserRole role) => switch (role) {
        UserRole.buyer  => buyerRegister,
        UserRole.farmer => farmerRegister,
        UserRole.driver => driverRegister,
      };
}

/// Application-level [GoRouter] instance.
///
/// Flow: Splash → Language → Onboarding → Role → Phone OTP → Dashboard.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.language,
      name: 'language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      name: 'roleSelection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.phoneAuth,
      name: 'phoneAuth',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.buyerRegister,
      name: 'buyerRegister',
      builder: (context, state) => const BuyerRegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.farmerRegister,
      name: 'farmerRegister',
      builder: (context, state) => const FarmerRegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverRegister,
      name: 'driverRegister',
      builder: (context, state) => const DriverRegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverDashboard,
      name: 'driverDashboard',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const BuyerHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.farmerDashboard,
      name: 'farmerDashboard',
      builder: (context, state) => const FarmerDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.farmerProducts,
      name: 'farmerProducts',
      builder: (context, state) => const FarmerProductsScreen(),
    ),
    GoRoute(
      path: AppRoutes.addEditProduct,
      name: 'addEditProduct',
      builder: (context, state) => const AddEditProductScreen(),
    ),
    GoRoute(
      path: AppRoutes.searchFilter,
      name: 'searchFilter',
      builder: (context, state) => const BuyerFilterScreen(),
    ),
    GoRoute(
      path: AppRoutes.ordersChat,
      name: 'ordersChat',
      builder: (context, state) => const OrdersChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.cart,
      name: 'cart',
      builder: (context, state) => const BuyerCartScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: 'checkout',
      builder: (context, state) => const CheckoutDeliveryScreen(),
    ),
  ],
);
