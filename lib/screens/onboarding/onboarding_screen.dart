import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      eyebrow: 'CARGA MENTAL',
      title: 'O peso invisível\ndo que você lembra',
      description:
          'Quem lembra do remédio. Quem decide o cardápio. Quem executa a entrega. NEXO equilibra esses três pesos.',
      icon: Icons.psychology_outlined,
    ),
    _OnboardingPage(
      eyebrow: 'MÉTODO L.D.E.',
      title: 'Uma tarefa,\ntrês donos',
      description:
          'Lembrar, Decidir e Executar contam pontos separados. Pela primeira vez, o trabalho mental aparece nos números.',
      icon: Icons.tune_rounded,
    ),
    _OnboardingPage(
      eyebrow: 'AUTOMÁTICO',
      title: 'Sua mente\npode descansar',
      description:
          'Lembretes inteligentes, planejamento semanal e check-in da família. Você foca no que importa.',
      icon: Icons.notifications_active_outlined,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(duration: NexoMotion.slow, curve: NexoMotion.standard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: NexoSpace.lg, top: NexoSpace.sm),
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(foregroundColor: fgMuted),
                    child: const Text('Pular',
                        style: TextStyle(fontSize: NexoText.sm, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _OnboardingPageView(page: _pages[i], dark: dark),
                ),
              ),

              // Footer (indicators + button)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    NexoSpace.xl, NexoSpace.md, NexoSpace.xl, NexoSpace.xl),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = _currentPage == i;
                        return AnimatedContainer(
                          duration: NexoMotion.normal,
                          curve: NexoMotion.standard,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: active ? 22 : 6,
                          decoration: BoxDecoration(
                            color: active
                                ? (dark ? NexoColors.indigoSoft : NexoColors.indigo)
                                : (dark ? NexoColors.darkBorder : NexoColors.lightBorder)
                                    .withOpacity(active ? 1 : 0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: NexoSpace.xl),
                    AppButton(
                      label: _currentPage == _pages.length - 1 ? 'Começar' : 'Próximo',
                      iconRight: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
  });
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page, required this.dark});
  final _OnboardingPage page;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NexoSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(NexoRadius.lg),
              border: Border.all(color: accent.withOpacity(0.20)),
            ),
            child: Icon(page.icon, color: accent, size: 28),
          ),
          const SizedBox(height: NexoSpace.xxl),
          Text(
            page.eyebrow,
            style: TextStyle(
              fontSize: NexoText.xs,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: accent,
            ),
          ),
          const SizedBox(height: NexoSpace.md),
          Text(
            page.title,
            style: AppTheme.display(size: 36, weight: FontWeight.w800, color: fg),
          ),
          const SizedBox(height: NexoSpace.lg),
          Text(
            page.description,
            style: TextStyle(
              fontSize: NexoText.base,
              height: 1.55,
              color: fgMuted,
            ),
          ),
        ],
      ),
    );
  }
}
