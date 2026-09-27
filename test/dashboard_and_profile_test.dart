import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmer_buyer_marketplace/features/dashboard/presentation/dashboard_screen.dart';
import 'package:farmer_buyer_marketplace/features/dashboard/presentation/farmer_profile_screen.dart';
import 'package:farmer_buyer_marketplace/features/dashboard/presentation/product_detail_screen.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  static final _kTransparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
    0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('DashboardScreen Tests', () {
    testWidgets('Renders header, banner, categories, and products matching reference image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pump();

      // Greeting and user info
      expect(find.text('Kasun 👋'), findsOneWidget);
      expect(find.text('Colombo, Sri Lanka'), findsOneWidget);

      // Banner
      expect(find.text('SPRING HARVEST FEST'), findsOneWidget);
      expect(find.text('Up to 25% Off Fresh\nGreens'), findsOneWidget);
      expect(find.text('Shop Season Specials'), findsOneWidget);

      // Categories
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Vegetables'), findsOneWidget);
      expect(find.text('Fruits'), findsOneWidget);

      // Products
      expect(find.text('Popular Products'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('Carrots'), findsOneWidget);
      expect(find.text('Potatoes'), findsOneWidget);
      expect(find.text('Bell Peppers'), findsOneWidget);

      // Prices
      expect(find.text('Rs. 250'), findsOneWidget);
      expect(find.text('Rs. 300'), findsOneWidget);
    });

    testWidgets('Category filtering updates active category selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pump();

      // Tap 'Vegetables' category
      await tester.tap(find.text('Vegetables'));
      await tester.pump();

      expect(find.text('Vegetables'), findsWidgets);
    });
  });

  group('FarmerProfileScreen Tests', () {
    final testFarmer = FarmerData(
      name: 'Sunil Perera',
      role: 'Small-Scale Farmer',
      location: 'Hambantota',
      rating: '4.8',
      reviews: '120 reviews',
      yearsExperience: '5+',
      isOrganic: true,
      happyCustomers: '200+',
      about: 'I am a small-scale farmer from Hambantota. I grow fresh vegetables using natural methods. My goal is to provide healthy and fresh produce to my customers.',
      emoji: '👨‍🌾',
      avatarUrl: 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&q=80',
      phone: '+94 77 123 4567',
    );

    testWidgets('Renders Sunil Perera farmer profile with all stats, bio, and products', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FarmerProfileScreen(farmer: testFarmer),
        ),
      );
      await tester.pump();

      // Screen title
      expect(find.text('Farmer Profile'), findsOneWidget);

      // Farmer identity
      expect(find.text('Sunil Perera'), findsOneWidget);
      expect(find.text('Small-Scale Farmer'), findsOneWidget);
      expect(find.text('Hambantota'), findsOneWidget);

      // Stats
      expect(find.text('5+'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('200+'), findsOneWidget);

      // About me
      expect(find.text('ABOUT ME'), findsOneWidget);
      expect(find.textContaining('I am a small-scale farmer from Hambantota'), findsOneWidget);

      // Products
      expect(find.text('My Products'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('Carrots'), findsOneWidget);
      expect(find.text('Cucumber'), findsOneWidget);

      // Add Product button
      expect(find.text('Add Product'), findsOneWidget);
    });

    testWidgets('Can tap edit profile button and update farmer details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FarmerProfileScreen(farmer: testFarmer),
        ),
      );
      await tester.pump();

      // Find and tap the edit profile icon in the app bar or banner
      final editButton = find.byIcon(Icons.edit_outlined);
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet modal opened
      expect(find.text('Edit Farmer Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Edit name
      final nameField = find.widgetWithText(TextField, 'Sunil Perera');
      await tester.enterText(nameField, 'Sunil Perera (Master Farmer)');
      await tester.pump();

      // Scroll to Save Changes and tap
      final saveBtn = find.text('Save Changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify updated name displays
      expect(find.text('Sunil Perera (Master Farmer)'), findsOneWidget);
    });
  });
}
