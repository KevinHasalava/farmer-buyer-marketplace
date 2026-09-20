import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract final class AppRoutes {
  static const String welcome    = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login      = '/login';
  static const String dashboard  = '/dashboard';
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
  ],
);
