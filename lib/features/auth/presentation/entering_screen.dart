import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Premium "getting things ready" page shown between sign-in / registration
/// and the role dashboard. Receives `{'role': 'buyer', 'name': 'Kevin',
/// 'isNew': true}` through `GoRouterState.extra`.
class EnteringScreen extends StatefulWidget {
  const EnteringScreen({super.key, this.role, this.name, this.isNew = false});

  final UserRole? role;
  final String? name;
  final bool isNew;

  @override
  State<EnteringScreen> createState() => _EnteringScreenState();
}

class _EnteringScreenState extends State<EnteringScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final UserRole _role = widget.role ?? UserRole.buyer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 350), _go);
      }
    });
  }

  void _go() {
    if (!mounted || _left) return;
    _left = true;
    context.go(AppRoutes.homeFor(_role));
  }

  @override
  void dispose() {
    _progress.dispose();
    _pulse.dispose();
    _intro.dispose();
    super.dispose();
  }

  IconData get _icon => switch (_role) {
        UserRole.farmer => Icons.agriculture_rounded,
        UserRole.buyer => Icons.shopping_basket_rounded,
        UserRole.driver => Icons.local_shipping_rounded,
      };

  String get _roleLabel => switch (_role) {
        UserRole.farmer => 'Farmer',
        UserRole.buyer => 'Buyer',
        UserRole.driver => 'Driver',
      };

  List<String> get _messages => switch (_role) {
        UserRole.farmer => const [
            'Securing your account...',
            'Loading your farm dashboard...',
            'Connecting you with buyers...',
            'Almost ready',
          ],
        UserRole.buyer => const [
            'Securing your account...',
            'Finding fresh produce near you...',
            'Preparing your marketplace...',
            'Almost ready',
          ],
        UserRole.driver => const [
            'Securing your account...',
            'Loading nearby deliveries...',
            'Preparing your route map...',
            'Almost ready',
          ],
      };

  @override
  Widget build(BuildContext context) {
    final name = (widget.name ?? '').trim();
    final first = name.isEmpty ? '' : name.split(' ').first;
    final greeting = widget.isNew ? 'Welcome to Farm2Home' : 'Welcome back';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF021B10), Color(0xFF052F1E), Color(0xFF09462B)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -70,
              child: _glow(260, const Color(0xFF10B981), 0.14),
            ),
            Positioned(
              bottom: 60,
              left: -90,
              child: _glow(280, const Color(0xFF059669), 0.12),
            ),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                      parent: _intro, curve: Curves.easeOut),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, child) => Transform.scale(
                            scale: 1 + 0.06 * _pulse.value,
                            child: child,
                          ),
                          child: const AppBrandLogo(size: 110, hasGlow: true),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          first.isEmpty
                              ? greeting.trAuto(context)
                              : '${greeting.trAuto(context)},',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (first.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            first,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_icon,
                                  size: 16, color: const Color(0xFF34D399)),
                              const SizedBox(width: 7),
                              Text(
                                _roleLabel.trAuto(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) {
                            final p =
                                Curves.easeInOut.transform(_progress.value);
                            final msgs = _messages;
                            final i = (p * msgs.length)
                                .floor()
                                .clamp(0, msgs.length - 1);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 220,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: p.clamp(0.03, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          Color(0xFF34D399),
                                          Color(0xFF10B981),
                                          Color(0xFFFBBF24),
                                        ]),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF34D399)
                                                .withValues(alpha: 0.6),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    msgs[i].trAuto(context),
                                    key: ValueKey(i),
                                    style: TextStyle(
                                      color: const Color(0xFFD1FAE5)
                                          .withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color c, double a) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withValues(alpha: a),
        ),
      );
}
