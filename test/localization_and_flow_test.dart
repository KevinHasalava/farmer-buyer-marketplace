import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farmer_buyer_marketplace/core/localization/app_settings.dart';
import 'package:farmer_buyer_marketplace/core/routes/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization and AppSettings Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads initial AppSettings and updates language', () async {
      final settings = await AppSettings.load();
      expect(settings.hasLanguage, isFalse);
      expect(settings.language, isNull);

      await settings.setLanguage(AppLanguage.sinhala);
      expect(settings.hasLanguage, isTrue);
      expect(settings.language, AppLanguage.sinhala);
      expect(settings.strings.lang, AppLanguage.sinhala);

      // Verify Sinhala localized strings
      expect(settings.strings.appName, 'Farm2Home');
      expect(settings.strings.roleFarmer, 'මම ගොවිතැන් කරනවා');
      expect(settings.strings.roleBuyer, 'මම මිලදී ගන්නවා');
      expect(settings.strings.roleDriver, 'මම රිය පදවනවා');

      // Switch to Tamil
      await settings.setLanguage(AppLanguage.tamil);
      expect(settings.language, AppLanguage.tamil);
      expect(settings.strings.roleFarmer, 'நான் விவசாயம் செய்கிறேன்');
      expect(settings.strings.roleBuyer, 'நான் வாங்குகிறேன்');
      expect(settings.strings.roleDriver, 'நான் வாகனம் ஓட்டுகிறேன்');

      // Switch to English
      await settings.setLanguage(AppLanguage.english);
      expect(settings.language, AppLanguage.english);
      expect(settings.strings.roleFarmer, "I'm Farming");
      expect(settings.strings.roleBuyer, "I'm Buying");
      expect(settings.strings.roleDriver, "I'm Driving");
    });

    test('Onboarding completion and role persistence', () async {
      final settings = await AppSettings.load();
      expect(settings.onboardingSeen, isFalse);
      expect(settings.role, isNull);

      await settings.completeOnboarding();
      expect(settings.onboardingSeen, isTrue);

      await settings.setRole(UserRole.driver);
      expect(settings.role, UserRole.driver);

      await settings.clearRole();
      expect(settings.role, isNull);
    });

    test('Role based home route mapping', () {
      expect(AppRoutes.homeFor(UserRole.buyer), AppRoutes.dashboard);
      expect(AppRoutes.homeFor(UserRole.farmer), AppRoutes.farmerDashboard);
      expect(AppRoutes.homeFor(UserRole.driver), AppRoutes.driverDashboard);
    });
  });
}
