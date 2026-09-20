import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_router.dart';

/// Login / Create Account screen — placeholder matching the Figma design.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isBuyer = true;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppDimensions.spaceXL,
              bottom: AppDimensions.spaceXL,
            ),
            color: AppColors.darkGreen,
            child: Column(
              children: [
                const Icon(
                  Icons.eco_rounded,
                  color: AppColors.accentOrange,
                  size: 36,
                ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  'Farm2Home',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.surfaceWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'FRESH • DIRECT • HONEST',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.7),
                    letterSpacing: AppTextStyles.trackingWidest,
                  ),
                ),
              ],
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppDimensions.spaceXXS),
                    Text(
                      'Takes less than a minute',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceLG),

                    // Account type selector
                    Text(
                      'SELECT YOUR ACCOUNT TYPE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: AppTextStyles.trackingWidest,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXS),
                    Row(
                      children: [
                        Expanded(
                          child: _AccountTypeCard(
                            label: "I'm Buying",
                            sublabel: 'Household & Dining',
                            icon: Icons.shopping_basket_rounded,
                            isSelected: _isBuyer,
                            onTap: () => setState(() => _isBuyer = true),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: _AccountTypeCard(
                            label: "I'm Farming",
                            sublabel: 'Sell Direct to Buyers',
                            icon: Icons.agriculture_rounded,
                            isSelected: !_isBuyer,
                            onTap: () => setState(() => _isBuyer = false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spaceLG),

                    // Full Name
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),

                    // Email
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),

                    // Phone
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+94  77 123 4567',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),

                    // Password
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXS),
                          ),
                          onChanged: (val) =>
                              setState(() => _agreedToTerms = val ?? false),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spaceLG),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.dashboard),
                        child: const Text('Create Account  →'),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // Sign in link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.spaceSM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.08)
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary,
              size: AppDimensions.iconMD,
            ),
            const SizedBox(width: AppDimensions.spaceXS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
