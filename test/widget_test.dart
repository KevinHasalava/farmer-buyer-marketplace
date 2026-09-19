// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:farmer_buyer_marketplace/main.dart';

void main() {
  testWidgets('marketplace home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmerBuyerMarketplaceApp());

    expect(find.text('Farmer Buyer Marketplace'), findsOneWidget);
    expect(find.text('Open login'), findsOneWidget);
  });
}
