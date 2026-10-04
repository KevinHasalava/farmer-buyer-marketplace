import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Step 1 (mandatory) — pick සිංහල / தமிழ் / English.
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
    // Live preview: the screen text switches as soon as a card is tapped.
    final preview = _selected == null ? null : AppStrings(_selected!);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header icon ─────────────────────────────────────────────
                FadeSlideIn(
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                              colors: AppColors.goldGradient),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.translate_rounded,
                            color: AppColors.forestDeep, size: 26),
                      ),
                      const Spacer(),
                      Text(
                        '1 / 4',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title (trilingual until a choice is made) ───────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: preview == null
                        ? Column(
                            key: const ValueKey('multi'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title('භාෂාව තෝරන්න', 28),
                              const SizedBox(height: 4),
                              _title('மொழியைத் தேர்ந்தெடுக்கவும்', 20,
                                  alpha: 0.75),
                              const SizedBox(height: 2),
                              _title('Choose your language', 20, alpha: 0.55),
                            ],
                          )
                        : Column(
                            key: ValueKey(_selected),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title(preview.chooseLanguage, 28),
                              const SizedBox(height: 10),
                              Text(
                                preview.chooseLanguageSub,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Language cards ──────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppLanguage.values.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final lang = AppLanguage.values[i];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 220 + i * 110),
                        child: _LanguageCard(
                          language: lang,
                          selected: _selected == lang,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selected = lang);
                          },
                        ),
                      );
                    },
                  ),
                ),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  child: GradientButton(
                    label: preview?.continueBtn ?? 'ඉදිරියට  •  தொடரவும்  •  Continue',
                    onPressed: _selected == null ? null : _continue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text, double size, {double alpha = 1}) => Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: alpha),
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: -0.3,
        ),
      );
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  String get _subtitle => switch (language) {
        AppLanguage.sinhala => 'Sinhala  •  සිංහල භාෂාවෙන් ඉදිරියට',
        AppLanguage.tamil => 'Tamil  •  தமிழில் தொடரவும்',
        AppLanguage.english => 'English  •  Continue in English',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.98,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: const EdgeInsets.all(1.6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: selected
                ? const LinearGradient(colors: AppColors.goldGradient)
                : LinearGradient(colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.05),
                  ]),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.5),
              color: selected
                  ? const Color(0xFF14301F)
                  : AppColors.forest.withValues(alpha: 0.85),
            ),
            child: Row(
              children: [
                // Glyph badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: selected
                        ? const LinearGradient(colors: AppColors.goldGradient)
                        : null,
                    color: selected ? null : Colors.white.withValues(alpha: 0.07),
                  ),
                  child: Text(
                    language.glyph,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.forestDeep : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.nativeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.gold : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.gold
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            key: ValueKey('on'),
                            size: 18,
                            color: AppColors.forestDeep)
                        : const SizedBox(key: ValueKey('off')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
