import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:farmer_buyer_marketplace/core/localization/app_settings.dart';
import 'package:farmer_buyer_marketplace/core/localization/app_strings.dart';
import 'package:farmer_buyer_marketplace/widgets/premium/premium_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tri-lingual AppStrings Dictionary Tests', () {
    test('English dictionary yields correct strings', () {
      const strings = AppStrings(AppLanguage.english);
      expect(strings.appName, 'Farm2Home');
      expect(strings.navHome, 'Home');
      expect(strings.navOrders, 'Orders');
      expect(strings.navChat, 'Chat');
      expect(strings.farmerDashboard, 'Farmer Dashboard');
      expect(strings.quickActions, 'QUICK ACTIONS');
      expect(strings.recentOrders, 'Recent Orders');
      expect(strings.todaysEarnings, 'Today\'s earnings');
    });

    test('Sinhala (සිංහල) dictionary yields authentic Sinhala strings', () {
      const strings = AppStrings(AppLanguage.sinhala);
      expect(strings.appName, 'Farm2Home');
      expect(strings.navHome, 'මුල් පිටුව');
      expect(strings.navOrders, 'ඇණවුම්');
      expect(strings.navChat, 'සංවාද');
      expect(strings.farmerDashboard, 'ගොවි උපකරණ පුවරුව');
      expect(strings.quickActions, 'ක්ෂණික ක්‍රියා');
      expect(strings.recentOrders, 'මෑත ඇණවුම්');
      expect(strings.todaysEarnings, 'අද ආදායම');
      expect(strings.signIn, 'ඇතුල් වන්න');
      expect(strings.buyer, 'මිලදී ගන්නා');
      expect(strings.farmer, 'ගොවියා');
      expect(strings.driver, 'රියදුරු');
    });

    test('Tamil (தமிழ்) dictionary yields authentic Tamil strings', () {
      const strings = AppStrings(AppLanguage.tamil);
      expect(strings.appName, 'Farm2Home');
      expect(strings.navHome, 'முகப்பு');
      expect(strings.navOrders, 'ஆர்டர்கள்');
      expect(strings.navChat, 'அரட்டை');
      expect(strings.farmerDashboard, 'விவசாயி டாஷ்போர்டு');
      expect(strings.recentOrders, 'சமீபத்திய ஆர்டர்கள்');
      expect(strings.todaysEarnings, 'இன்றைய வருமானம்');
      expect(strings.signIn, 'உள்நுழைக');
      expect(strings.buyer, 'வாங்குபவர்');
      expect(strings.farmer, 'விவசாயி');
      expect(strings.driver, 'ஓட்டுநர்');
    });
  });

  group('Reactive AppSettings & UI Language Switching Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Switching language in AppSettings reactively rebuilds context.tr',
        (tester) async {
      final settings = await AppSettings.load();
      await settings.setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppSettings>.value(
          value: settings,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text('CURRENT_LANG: ${context.tr.navHome}'),
                      const AppLanguagePill(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initially English
      expect(find.text('CURRENT_LANG: Home'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Switch to Sinhala
      await settings.setLanguage(AppLanguage.sinhala);
      await tester.pumpAndSettle();

      expect(find.text('CURRENT_LANG: මුල් පිටුව'), findsOneWidget);
      expect(find.text('සිංහල'), findsOneWidget);

      // Switch to Tamil
      await settings.setLanguage(AppLanguage.tamil);
      await tester.pumpAndSettle();

      expect(find.text('CURRENT_LANG: முகப்பு'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
    });

    testWidgets('Tapping AppLanguagePill opens language bottom sheet and selects language',
        (tester) async {
      final settings = await AppSettings.load();
      await settings.setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppSettings>.value(
          value: settings,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppLanguagePill(),
              ),
            ),
          ),
        ),
      );

      // Tap on the language pill
      await tester.tap(find.byType(AppLanguagePill));
      await tester.pumpAndSettle();

      // Bottom sheet should be visible showing all 3 options
      expect(find.text('සිංහල'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('English'), findsWidgets);

      // Tap Sinhala option
      await tester.tap(find.text('සිංහල'));
      await tester.pumpAndSettle();

      // Settings must now be Sinhala and persisted
      expect(settings.language, AppLanguage.sinhala);
    });
  });
}
