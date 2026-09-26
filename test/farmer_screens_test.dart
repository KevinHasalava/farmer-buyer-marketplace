import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_buyer_marketplace/features/farmer/presentation/farmer_dashboard_screen.dart';
import 'package:farmer_buyer_marketplace/features/farmer/presentation/farmer_products_screen.dart';
import 'package:farmer_buyer_marketplace/features/farmer/presentation/add_edit_product_screen.dart';

void main() {
  testWidgets('FarmerDashboardScreen renders all key sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Greeting
    expect(find.text('Farmer Dashboard'), findsOneWidget);
    expect(find.textContaining('Sunil'), findsAtLeastNWidgets(1));
    expect(find.text("Here's your farm overview"), findsOneWidget);

    // Verify Profile Card
    expect(find.text('Sunil Perera'), findsOneWidget);
    expect(find.text('Small-Scale Farmer'), findsOneWidget);
    expect(find.text('Hambantota'), findsOneWidget);

    // Verify Stats
    expect(find.text('Active Products'), findsOneWidget);
    expect(find.text('New Orders'), findsOneWidget);
    expect(find.text('Completed Orders'), findsOneWidget);
    expect(find.text('This Week Earnings'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('My Products'), findsOneWidget);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Messages'), findsOneWidget);

    // Verify Recent Orders
    expect(find.text('Recent Orders'), findsOneWidget);
    expect(find.textContaining('Nadeesha Fernando'), findsOneWidget);
    expect(find.textContaining('Kasun Perera'), findsOneWidget);
  });

  testWidgets('FarmerProductsScreen renders list, filters, and add button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerProductsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Products'), findsOneWidget);
    expect(find.text('All Products'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('+ Add New Product'), findsOneWidget);

    // Products
    expect(find.text('Tomatoes'), findsOneWidget);
    expect(find.text('Carrots'), findsOneWidget);
    expect(find.text('Cucumber'), findsOneWidget);
  });

  testWidgets('AddEditProductScreen renders form inputs and save button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddEditProductScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add/Edit Product'), findsOneWidget);
    expect(find.text('Add Photo'), findsOneWidget);
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Price per Kg (Rs.)'), findsOneWidget);
    expect(find.text('Available Quantity (kg)'), findsOneWidget);
    expect(find.text('Harvest Date'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Organic'), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Save Product'), findsOneWidget);
  });
}
