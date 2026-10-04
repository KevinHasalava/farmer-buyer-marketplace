import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';
import 'role_meta.dart';

/// Step 3 — pick a role: Buyer, Farmer or Driver.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.settings.role;
  }

  Future<void> _continue() async {
    final role = _selected;
    if (role == null) return;
    await context.settings.setRole(role);
    if (mounted) context.push(AppRoutes.phoneAuth);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final accent = _selected?.gradient;

    return Scaffold(
      body: AuroraBackground(
        accent: accent?.first ?? const Color(0xFF34D399),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ─────────────────────────────────────────────────
                Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.go(AppRoutes.onboarding),
                    ),
                    const Spacer(),
                    const LanguagePill(),
                  ],
                ),
                const SizedBox(height: 20),
                const StepIndicator(total: 4, current: 2),
                const SizedBox(height: 28),

                FadeSlideIn(
                  child: Text(
                    tr.whoAreYou,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: Text(
                    tr.whoAreYouSub,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Role cards ──────────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: UserRole.values.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final role = UserRole.values[i];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 160 + i * 110),
                        child: _RoleCard(
                          role: role,
                          title: role.label(tr),
                          subtitle: role.subtitle(tr),
                          selected: _selected == role,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selected = role);
                          },
                        ),
                      );
                    },
                  ),
                ),

                GradientButton(
                  label: tr.continueBtn,
                  colors: accent ?? const [Color(0xFFFFD27A), Color(0xFFF5A623)],
                  foreground: _selected == null || _selected == UserRole.buyer
                      ? const Color(0xFF03140D)
                      : Colors.white,
                  onPressed: _selected == null ? null : _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = role.gradient;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(1.6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: selected
              ? LinearGradient(colors: g)
              : LinearGradient(colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.05),
                ]),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: g.last.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.5),
            color: const Color(0xFF082A1C).withValues(alpha: 0.92),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      g.first.withValues(alpha: 0.18),
                      const Color(0xFF082A1C).withValues(alpha: 0.95),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon tile
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selected
                        ? g
                        : [
                            g.first.withValues(alpha: 0.22),
                            g.last.withValues(alpha: 0.12),
                          ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(role.icon,
                        size: 34, color: selected ? Colors.white : g.first),
                    Positioned(
                      right: 4,
                      bottom: 2,
                      child: Text(role.emoji,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected ? LinearGradient(colors: g) : null,
                  border: selected
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 2,
                        ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
