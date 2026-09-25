import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_products_screen.dart';
import '../../features/farmer/presentation/add_edit_product_screen.dart';
import '../../features/search/presentation/search_filter_screen.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract final class AppRoutes {
  static const String welcome         = '/welcome';
  static const String onboarding      = '/onboarding';
  static const String login           = '/login';
  static const String dashboard       = '/dashboard';
  static const String farmerDashboard = '/farmer-dashboard';
  static const String farmerProducts  = '/farmer-products';
  static const String addEditProduct  = '/add-edit-product';
  static const String searchFilter    = '/search-filter';
}

/// Application-level [GoRouter] instance.
///
/// Initial location is `/welcome` (splash / landing).
final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  debugLogDiagnostics: true,
  routes: [
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
      builder: (context, state) => const DashboardScreen(),
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
      builder: (context, state) => const SearchFilterScreen(),
    ),
  ],
);
