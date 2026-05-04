import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/cycle_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/family_pulse.dart';
import '../../core/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final cycleProvider = context.watch<CycleProvider>();

    final loadPercent = taskProvider.totalMentalLoad.clamp(0, 100).toDouble();

    final me = memberProvider.currentMember;
    final fallbackName = memberProvider.members.isNotEmpty
        ? memberProvider.members.first.name.split(' ').first
        : 'Família';
    final firstName = me?.name.split(' ').first ?? fallbackName;
    final greeting = _greeting();

    final segments = _buildSegments(memberProvider, taskProvider);

    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: _Avatar(
            initial: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'N',
            color: me != null
                ? Color(int.tryParse(me.color) ?? 0xFF5E6AD2)
                : NexoColors.indigo,
            onTap: () => context.push('/profile'),
          ),
        ),
        title: Text(
          'NEXO',
          style: AppTheme.display(size: NexoText.lg, weight: FontWeight.w800, color: fg)
              .copyWith(letterSpacing: 2),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_rounded, color: fg),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AmbientBackground(
        intensity: 0.7,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                NexoSpace.xl, NexoSpace.lg, NexoSpace.xl, NexoSpace.xxxl + 60),
            children: [
              const SizedBox(height: 56),
              Text(
                '$greeting,',
                style: TextStyle(fontSize: NexoText.base, color: fgMuted),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                style: AppTheme.display(size: NexoText.xxl, weight: FontWeight.w800, color: fg),
              ),
              const SizedBox(height: NexoSpace.xl),

              // ── HERO: Pulso da Família ───────────────────────────────────
              Center(
                child: FamilyPulse(
                  totalLoad: loadPercent,
                  segments: segments,
                  onTap: () => context.push('/mental-load-history'),
                ),
              ),
              const SizedBox(height: NexoSpace.lg),
              Center(
                child: Text(
                  segments.isEmpty
                      ? 'Cadastre tarefas para ver a carga da família'
                      : 'Toque para ver o histórico',
                  style: TextStyle(fontSize: NexoText.sm, color: fgMuted),
                ),
              ),

              // ── BIO-RITMO ────────────────────────────────────────────────
              if (memberProvider.members.isNotEmpty) ...[
                const SizedBox(height: NexoSpace.xxl),
                _CycleStrip(
                  cycleProvider: cycleProvider,
                  memberId: memberProvider.members.first.id,
                ),
              ],

              // ── ATALHOS ──────────────────────────────────────────────────
              SectionHeader(
                title: 'Atalhos',
                subtitle: 'Tudo que vocês mais usam.',
                actionLabel: 'Estatísticas',
                onAction: () => context.push('/stats'),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: NexoSpace.md,
                mainAxisSpacing: NexoSpace.md,
                childAspectRatio: 1.05,
                children: [
                  _ShortcutCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Planejamento',
                    subtitle: 'Semanal',
                    accent: NexoColors.indigo,
                    onTap: () => context.push('/planning'),
                  ),
                  _ShortcutCard(
                    icon: Icons.sports_esports_outlined,
                    title: 'Modo filho',
                    subtitle: 'Gamificação',
                    accent: const Color(0xFF8B5CF6),
                    onTap: () => context.push('/kid-mode'),
                  ),
                  _ShortcutCard(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Refeições',
                    subtitle: 'Cardápio',
                    accent: const Color(0xFFF97316),
                    onTap: () => context.push('/meals'),
                  ),
                  _ShortcutCard(
                    icon: Icons.bolt_outlined,
                    title: 'Check-in',
                    subtitle: 'Avaliar a semana',
                    accent: const Color(0xFFF59E0B),
                    onTap: () => context.push('/checkin'),
                  ),
                  _ShortcutCard(
                    icon: Icons.handshake_outlined,
                    title: 'Acordos',
                    subtitle: 'Combinados',
                    accent: const Color(0xFFEC4899),
                    onTap: () => context.push('/agreements'),
                  ),
                  _ShortcutCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'Estatísticas',
                    subtitle: 'Relatórios',
                    accent: const Color(0xFF10B981),
                    onTap: () => context.push('/stats'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 18 || h < 5) return 'Boa noite';
    if (h >= 12) return 'Boa tarde';
    return 'Bom dia';
  }

  static List<FamilyPulseSegment> _buildSegments(
    MemberProvider mp,
    TaskProvider tp,
  ) {
    if (mp.members.isEmpty) return const [];
    final list = <FamilyPulseSegment>[];
    for (final m in mp.members) {
      final byId = tp.getMemberMentalLoad(m.id).toDouble();
      final byName = tp.calculateMentalLoad(m.name)['total']?.toDouble() ?? 0;
      final weight = byId > byName ? byId : byName;
      if (weight <= 0) continue;
      final color = Color(int.tryParse(m.color) ?? 0xFF5E6AD2);
      list.add(FamilyPulseSegment(color: color, weight: weight, label: m.name));
    }
    return list;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.color, required this.onTap});
  final String initial;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ver meu perfil',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: NexoElevation.glow(color, opacity: 0.25),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style:
                AppTheme.display(size: NexoText.md, weight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(NexoSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(NexoRadius.sm),
              border: Border.all(color: accent.withOpacity(0.20)),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTheme.display(size: NexoText.base, weight: FontWeight.w700, color: fg),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: NexoText.sm, color: fgMuted),
          ),
        ],
      ),
    );
  }
}

class _CycleStrip extends StatelessWidget {
  const _CycleStrip({required this.cycleProvider, required this.memberId});
  final CycleProvider cycleProvider;
  final String memberId;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final info = cycleProvider.getCurrentPhaseInfo(memberId);
    final hasData = info['hasData'] == true;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    if (!hasData) {
      return AppCard(
        onTap: () => GoRouter.of(context).push('/cycle-settings'),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withOpacity(0.12),
                borderRadius: BorderRadius.circular(NexoRadius.sm),
                border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.20)),
              ),
              child: const Icon(Icons.favorite_outline, color: Color(0xFFEC4899), size: 20),
            ),
            const SizedBox(width: NexoSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurar bio-ritmo',
                    style:
                        AppTheme.display(size: NexoText.base, weight: FontWeight.w700, color: fg),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Acompanhe o ciclo e receba dicas.',
                    style: TextStyle(fontSize: NexoText.sm, color: fgMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: fgMuted),
          ],
        ),
      );
    }

    final color = info['color'] as Color;
    final phase = info['phase'] as String;
    final tip = info['tip'] as String;
    final day = info['day'] as int;
    final progress = (day / 28).clamp(0.0, 1.0);

    return AppCard(
      glow: color,
      onTap: () => GoRouter.of(context).push('/cycle-settings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(NexoRadius.sm),
                  border: Border.all(color: color.withOpacity(0.20)),
                ),
                child: Icon(info['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: NexoSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio-ritmo',
                      style: TextStyle(
                        fontSize: NexoText.xs,
                        letterSpacing: 1.4,
                        color: fgMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      phase,
                      style: AppTheme.display(
                          size: NexoText.lg, weight: FontWeight.w700, color: fg),
                    ),
                  ],
                ),
              ),
              Text(
                'dia $day',
                style: AppTheme.mono(size: NexoText.sm, weight: FontWeight.w600, color: color),
              ),
            ],
          ),
          const SizedBox(height: NexoSpace.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(NexoRadius.xs),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: NexoSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_outlined, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(fontSize: NexoText.sm, color: fg, height: 1.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
