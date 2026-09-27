import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_buyer_marketplace/features/cart/presentation/checkout_delivery_screen.dart';
import 'package:farmer_buyer_marketplace/features/cart/presentation/my_cart_screen.dart';
import 'package:farmer_buyer_marketplace/features/orders_chat/presentation/orders_chat_screen.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('OrdersChatScreen Tests', () {
    testWidgets('Renders Orders & Chat screen with pill toggle and chat items',
        (tester) async {
      await tester.pumpWidget(buildTestable(const OrdersChatScreen(initialTab: 1)));
      await tester.pump();

      // Screen title
      expect(find.text('Orders & Chat'), findsOneWidget);

      // Pill toggle buttons
      expect(find.text('Orders'), findsWidgets);
      expect(find.text('Chat'), findsWidgets);

      // Chat list items matching Image 1
      expect(find.text('Nadeesha Fernando'), findsOneWidget);
      expect(find.text('Kasun Perera'), findsOneWidget);
      expect(find.text('Tharushi Silva'), findsOneWidget);
      expect(find.text('Saman Kumara'), findsOneWidget);
      expect(find.text('Dilshan'), findsOneWidget);

      // View All Chats button
      expect(find.text('View All Chats'), findsOneWidget);

      // Tap Orders tab to switch
      await tester.tap(find.text('Orders').first);
      await tester.pumpAndSettle();

      // Check order filters and order card
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('#FT-8291'), findsOneWidget);
    });
  });

  group('CheckoutDeliveryScreen Tests', () {
    testWidgets('Renders all cards and elements matching Image 2', (tester) async {
      await tester.pumpWidget(buildTestable(const CheckoutDeliveryScreen()));
      await tester.pump();

      // Header
      expect(find.text('Checkout & Delivery'), findsOneWidget);

      // Card Headers
      expect(find.text('DELIVERY ADDRESS'), findsOneWidget);
      expect(find.text('CONTACT NUMBER'), findsOneWidget);
      expect(find.text('DELIVERY METHOD'), findsOneWidget);
      expect(find.text('PREFERRED DATE & TIME'), findsOneWidget);
      expect(find.text('PAYMENT METHOD'), findsOneWidget);

      // Address & Phone
      expect(find.text('123, Main Street, Hambantota'), findsOneWidget);
      expect(find.text('076 323 8225'), findsOneWidget);

      // Delivery Options
      expect(find.text('Home Delivery'), findsOneWidget);
      expect(find.text('Self Pickup'), findsOneWidget);
      expect(find.text('Scheduled Delivery'), findsOneWidget);

      // Payment Options
      expect(find.text('Cash on Delivery'), findsOneWidget);

      // Order Total & Place Order CTA
      expect(find.text('Order Total'), findsOneWidget);
      expect(find.text('Rs. 950'), findsOneWidget);
      expect(find.text('Place Order'), findsOneWidget);
    });
  });

  group('MyCartScreen Tests', () {
    testWidgets('Renders cart items and checkout button', (tester) async {
      await tester.pumpWidget(buildTestable(const MyCartScreen()));
      await tester.pump();

      // Header
      expect(find.text('My Cart'), findsOneWidget);

      // Items in cart
      expect(find.text('Organic Tomatoes'), findsOneWidget);
      expect(find.text('Fresh Carrots'), findsOneWidget);

      // Summary and checkout
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });
  });
}
