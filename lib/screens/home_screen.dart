import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Farmer Buyer Marketplace')),
      body: Center(
        child: CustomButton(
          label: 'Open login',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
    );
  }
}
