import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Step 2: Language Selection Screen — matching original Login/Welcome design system.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage? _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.settings.language;
  }

  Future<void> _continue() async {
    final lang = _selected;
    if (lang == null) return;
    final s = context.settings;
    await s.setLanguage(lang);
    if (!mounted) return;
    context.go(s.onboardingSeen ? AppRoutes.roleSelection : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _selected == null ? null : AppStrings(_selected!);
    final titleText = preview?.chooseLanguage ?? 'භාෂාව තෝරන්න';
    final subText = preview?.chooseLanguageSub ??
        'Choose your language to customize your experience';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Signature Curved Header matching login_screen.dart ──────────
          AppHeaderBanner(
            title: titleText,
            subtitle: subText,
            badgeText: 'STEP 1 OF 3',
            heightFactor: 0.26,
          ),

          // ── Language Selection Cards ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                AppDimensions.spaceMD,
                AppDimensions.spaceLG,
                AppDimensions.spaceLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT YOUR PREFERRED LANGUAGE',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // Sinhala Card
                  AppSelectableCard(
                    title: AppLanguage.sinhala.nativeName,
                    subtitle: 'Sinhala  •  සිංහල භාෂාවෙන් ඉදිරියට යන්න',
                    icon: Icons.language_rounded,
                    iconEmoji: AppLanguage.sinhala.glyph,
                    isSelected: _selected == AppLanguage.sinhala,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = AppLanguage.sinhala);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // Tamil Card
                  AppSelectableCard(
                    title: AppLanguage.tamil.nativeName,
                    subtitle: 'Tamil  •  தமிழில் தொடர்ந்து செல்லுங்கள்',
                    icon: Icons.language_rounded,
                    iconEmoji: AppLanguage.tamil.glyph,
                    isSelected: _selected == AppLanguage.tamil,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = AppLanguage.tamil);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // English Card
                  AppSelectableCard(
                    title: AppLanguage.english.nativeName,
                    subtitle: 'English  •  Continue in English',
                    icon: Icons.language_rounded,
                    iconEmoji: AppLanguage.english.glyph,
                    isSelected: _selected == AppLanguage.english,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = AppLanguage.english);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Continue CTA ──────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                0,
                AppDimensions.spaceLG,
                AppDimensions.spaceLG,
              ),
              child: AppPrimaryButton(
                label: preview?.continueBtn ?? 'Continue  •  ඉදිරියට',
                onPressed: _selected == null ? null : _continue,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
