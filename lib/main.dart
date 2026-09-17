import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const FarmerBuyerMarketplaceApp());
}

class FarmerBuyerMarketplaceApp extends StatelessWidget {
  const FarmerBuyerMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Buyer Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
