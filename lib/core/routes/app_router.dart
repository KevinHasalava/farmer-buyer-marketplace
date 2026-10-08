import 'package:go_router/go_router.dart';

import '../localization/app_settings.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/language_selection_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/auth/presentation/buyer_registration_screen.dart';
import '../../features/auth/presentation/farmer_registration_screen.dart';
import '../../features/auth/presentation/driver_registration_screen.dart';
import '../../features/driver/presentation/driver_dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_products_screen.dart';
import '../../features/farmer/presentation/add_edit_product_screen.dart';
import '../../features/cart/presentation/checkout_delivery_screen.dart';
import '../../features/orders_chat/presentation/orders_chat_screen.dart';
import '../../features/driver/presentation/delivery_details_screen.dart';
import '../../features/driver/presentation/deliveries_screen.dart';
import '../../features/driver/presentation/pickup_verification_screen.dart';
import '../../features/driver/presentation/delivery_tracking_screen.dart';
import '../../features/driver/presentation/delivery_completed_screen.dart';
import '../../features/driver/presentation/driver_profile_screen.dart';
import '../../features/driver/presentation/delivery_history_screen.dart';
import '../../features/buyer/buyer.dart';
import '../../features/admin/presentation/admin_login_screen.dart';
import '../../features/admin/presentation/admin_panel_screen.dart';
import '../../features/admin/services/admin_auth_service.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract final class AppRoutes {
  static const String splash             = '/';
  static const String language           = '/language';
  static const String welcome            = '/welcome';
  static const String onboarding         = '/onboarding';
  static const String onboarding2        = '/onboarding-2';
  static const String onboarding3        = '/onboarding-3';
  static const String roleSelection      = '/role';
  static const String chooseRole         = '/role';
  static const String phoneAuth          = '/phone-auth';
  static const String login              = '/login';
  static const String buyerRegister      = '/register-buyer';
  static const String farmerRegister     = '/register-farmer';
  static const String driverRegister     = '/register-driver';
  static const String dashboard          = '/dashboard';
  static const String farmerDashboard    = '/farmer-dashboard';
  static const String driverDashboard    = '/driver-dashboard';
  static const String driverRegistration = '/driver-registration';
  static const String driverProfile      = '/driver-profile';
  static const String deliveryHistory    = '/delivery-history';
  static const String deliveryDetails    = '/delivery-details';
  static const String driverDeliveries   = '/driver-deliveries';
  static const String pickupVerification = '/pickup-verification';
  static const String deliveryTracking   = '/delivery-tracking';
  static const String deliveryCompleted  = '/delivery-completed';
  static const String farmerProducts     = '/farmer-products';
  static const String addEditProduct     = '/add-edit-product';
  static const String searchFilter       = '/search-filter';
  static const String ordersChat         = '/orders-chat';
  static const String cart               = '/cart';
  static const String checkout           = '/checkout';
  static const String buyerProfile       = '/buyer-profile';
  static const String buyerNotifications = '/buyer-notifications';
  static const String adminLogin         = '/admin/login';
  static const String adminPanel         = '/admin';

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
      path: AppRoutes.onboarding2,
      name: 'onboarding2',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding3,
      name: 'onboarding3',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.chooseRole,
      name: 'chooseRole',
      builder: (context, state) => const RoleSelectionScreen(),
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
      path: AppRoutes.driverDashboard,
      name: 'driverDashboard',
      builder: (context, state) {
        final extraMap = state.extra as Map<String, dynamic>?;
        final driverId = extraMap?['driverId'] as String?;
        final driverName = extraMap?['driverName'] as String?;
        final vehicleType = extraMap?['vehicleType'] as String?;
        final plateNumber = extraMap?['plateNumber'] as String?;
        final bankName = extraMap?['bankName'] as String?;
        final accountNumber = extraMap?['accountNumber'] as String?;
        final cargoCapacity = extraMap?['cargoCapacity'] as String?;
        final licenseNumber = extraMap?['licenseNumber'] as String?;
        return DriverDashboardScreen(
          driverId: driverId,
          driverName: driverName,
          vehicleType: vehicleType,
          plateNumber: plateNumber,
          bankName: bankName,
          accountNumber: accountNumber,
          cargoCapacity: cargoCapacity,
          licenseNumber: licenseNumber,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverRegistration,
      name: 'driverRegistration',
      builder: (context, state) => const DriverRegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.deliveryDetails,
      name: 'deliveryDetails',
      builder: (context, state) => const DeliveryDetailsScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverDeliveries,
      name: 'driverDeliveries',
      builder: (context, state) => const DeliveriesScreen(),
    ),
    GoRoute(
      path: AppRoutes.pickupVerification,
      name: 'pickupVerification',
      builder: (context, state) => const PickupVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.deliveryTracking,
      name: 'deliveryTracking',
      builder: (context, state) => const DeliveryTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.deliveryCompleted,
      name: 'deliveryCompleted',
      builder: (context, state) => const DeliveryCompletedScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverProfile,
      name: 'driverProfile',
      builder: (context, state) {
        final extraMap = state.extra as Map<String, dynamic>?;
        final driverId = extraMap?['driverId'] as String?;
        final driverName = extraMap?['driverName'] as String?;
        final vehicleType = extraMap?['vehicleType'] as String?;
        final plateNumber = extraMap?['plateNumber'] as String?;
        final bankName = extraMap?['bankName'] as String?;
        final accountNumber = extraMap?['accountNumber'] as String?;
        final cargoCapacity = extraMap?['cargoCapacity'] as String?;
        final licenseNumber = extraMap?['licenseNumber'] as String?;
        return DriverProfileScreen(
          driverId: driverId,
          driverName: driverName,
          vehicleType: vehicleType,
          plateNumber: plateNumber,
          bankName: bankName,
          accountNumber: accountNumber,
          cargoCapacity: cargoCapacity,
          licenseNumber: licenseNumber,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.deliveryHistory,
      name: 'deliveryHistory',
      builder: (context, state) => const DeliveryHistoryScreen(),
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
    GoRoute(
      path: AppRoutes.buyerProfile,
      name: 'buyerProfile',
      builder: (context, state) => const BuyerProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.buyerNotifications,
      name: 'buyerNotifications',
      builder: (context, state) => const BuyerNotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminLogin,
      name: 'adminLogin',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminPanel,
      name: 'adminPanel',
      redirect: (context, state) {
        if (!AdminAuthService.instance.isAuthenticated) {
          return AppRoutes.adminLogin;
        }
        return null;
      },
      builder: (context, state) => const AdminPanelScreen(),
    ),
  ],
);
