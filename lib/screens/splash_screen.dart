import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/ambient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _logo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  @override
  void dispose() {
    _logo.dispose();
    super.dispose();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    var retries = 0;
    while (auth.status == AuthGateStatus.initializing && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }
    if (!mounted) return;
    switch (auth.status) {
      case AuthGateStatus.authenticatedInFamily:
        context.go('/');
      case AuthGateStatus.authenticatedNoFamily:
        context.go('/setup-family');
      default:
        context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: AmbientBackground(
        intensity: 1.4,
        child: Center(
          child: AnimatedBuilder(
            animation: _logo,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(_logo.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Wordmark(dark: dark),
                      const SizedBox(height: NexoSpace.md),
                      Text(
                        'Equilibrando o invisível',
                        style: TextStyle(
                          fontSize: NexoText.sm,
                          letterSpacing: 1.2,
                          color: dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: NexoSpace.xxl),
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: dark ? NexoColors.indigoSoft : NexoColors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: NexoColors.indigo,
            borderRadius: BorderRadius.circular(10),
            boxShadow: NexoElevation.glow(NexoColors.indigo, opacity: 0.35),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'NEXO',
          style: AppTheme.display(size: 32, weight: FontWeight.w800, color: fg),
        ),
      ],
    );
  }
}
