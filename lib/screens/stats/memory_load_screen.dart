import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/app_card.dart';

const _dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/// Heatmap "quem lembra" — matriz membro × dia da semana mostrando quem
/// carrega o peso de lembrar. Insight automático no topo com a pessoa
/// que concentra mais % da memória.
class MemoryLoadScreen extends StatelessWidget {
  const MemoryLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();

    final dist = taskProvider.memoryLoadDistribution();
    final totals = taskProvider.memoryLoadTotalByMember();

    final allMemberNames = memberProvider.members.map((m) => m.name).toList();
    // Garante que todos os membros aparecem mesmo se não estão em nenhuma tarefa.
    for (final n in allMemberNames) {
      totals.putIfAbsent(n, () => 0);
      dist.putIfAbsent(n, () => {});
    }

    final sortedMembers = totals.keys.toList()
      ..sort((a, b) => totals[b]!.compareTo(totals[a]!));

    final maxValue = dist.values.fold<int>(
      1,
      (m, perDay) => perDay.values.fold<int>(m, (mm, v) => v > mm ? v : mm),
    );

    final totalAll = totals.values.fold<int>(0, (a, b) => a + b);
    final topMember = sortedMembers.isEmpty || totals[sortedMembers.first] == 0
        ? null
        : sortedMembers.first;
    final topPercent =
        topMember == null || totalAll == 0 ? 0 : ((totals[topMember]! / totalAll) * 100).round();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: fg),
          onPressed: () => context.pop(),
        ),
        title: const Text('Memória da casa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AmbientBackground(
        intensity: 0.5,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(NexoSpace.xl, 56, NexoSpace.xl, NexoSpace.xxxl),
            children: [
              const SizedBox(height: NexoSpace.lg),

              // ── Insight ──────────────────────────────────────────────────
              _Insight(topMember: topMember, topPercent: topPercent, total: totalAll),

              const SizedBox(height: NexoSpace.xl),
              Text(
                'QUEM LEMBRA × DIA DA SEMANA',
                style: TextStyle(
                  fontSize: NexoText.xs,
                  letterSpacing: 1.4,
                  color: fgMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: NexoSpace.md),
              AppCard(
                padding: const EdgeInsets.all(NexoSpace.md),
                child: sortedMembers.isEmpty
                    ? _EmptyHeatmap()
                    : _HeatmapMatrix(
                        members: sortedMembers,
                        dist: dist,
                        maxValue: maxValue,
                      ),
              ),

              const SizedBox(height: NexoSpace.lg),
              _Legend(maxValue: maxValue),

              const SizedBox(height: NexoSpace.xl),
              // ── Ranking ─────────────────────────────────────────────────
              Text(
                'CONCENTRAÇÃO POR PESSOA',
                style: TextStyle(
                  fontSize: NexoText.xs,
                  letterSpacing: 1.4,
                  color: fgMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: NexoSpace.md),
              AppCard(
                child: Column(
                  children: sortedMembers.map((name) {
                    final value = totals[name]!;
                    final pct = totalAll == 0 ? 0.0 : value / totalAll;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTheme.display(
                                    size: NexoText.base,
                                    weight: FontWeight.w700,
                                    color: fg,
                                  ),
                                ),
                              ),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: AppTheme.mono(
                                  size: NexoText.sm,
                                  weight: FontWeight.w700,
                                  color: NexoColors.indigo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(NexoRadius.xs),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: NexoColors.indigo.withOpacity(0.10),
                              valueColor: const AlwaysStoppedAnimation(NexoColors.indigo),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({required this.topMember, required this.topPercent, required this.total});
  final String? topMember;
  final num topPercent;
  final int total;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    String headline;
    String body;
    Color tone = NexoColors.indigo;

    if (total == 0) {
      headline = 'Sem tarefas mapeadas ainda';
      body = 'Cadastre responsabilidades para enxergar quem carrega a memória da casa.';
    } else if (topMember == null) {
      headline = 'Memória bem distribuída';
      body = 'Ninguém concentra a maior parte das lembranças. Continua assim.';
      tone = NexoColors.success;
    } else if (topPercent >= 60) {
      headline = '$topPercent% da memória da casa está com $topMember';
      body = 'Vale conversar sobre redistribuir parte do que precisa ser lembrado.';
      tone = NexoColors.danger;
    } else if (topPercent >= 40) {
      headline = '$topMember concentra $topPercent% das lembranças';
      body = 'Tá puxando boa parte. Considere passar algumas pra outra pessoa.';
      tone = NexoColors.warning;
    } else {
      headline = 'Memória relativamente equilibrada';
      body = '$topMember lidera com $topPercent%, mas o time tá bem distribuído.';
      tone = NexoColors.success;
    }

    return AppCard(
      glow: tone,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.12),
              borderRadius: BorderRadius.circular(NexoRadius.sm),
              border: Border.all(color: tone.withOpacity(0.20)),
            ),
            child: Icon(LucideIcons.brain, color: tone, size: 22),
          ),
          const SizedBox(width: NexoSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: AppTheme.display(size: NexoText.lg, weight: FontWeight.w700, color: fg),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(fontSize: NexoText.sm, color: fgMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapMatrix extends StatelessWidget {
  const _HeatmapMatrix({required this.members, required this.dist, required this.maxValue});
  final List<String> members;
  final Map<String, Map<int, int>> dist;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final maxNameWidth = (constraints.maxWidth * 0.30).clamp(80.0, 140.0);
        final cellWidth = (constraints.maxWidth - maxNameWidth - 16) / 7;

        return Column(
          children: [
            // Header com dias
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: maxNameWidth),
                  ..._dayLabels.map((d) => SizedBox(
                        width: cellWidth,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: NexoText.xs,
                            fontWeight: FontWeight.w700,
                            color: fgMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            // Linhas (uma por membro)
            ...members.map((name) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: maxNameWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: NexoText.sm,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(7, (i) {
                      final weekday = i + 1; // 1..7
                      final value = dist[name]?[weekday] ?? 0;
                      final intensity = maxValue == 0 ? 0.0 : value / maxValue;
                      return SizedBox(
                        width: cellWidth,
                        height: cellWidth - 4,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Tooltip(
                            message: '$name · ${_dayLabels[i]}: $value pontos',
                            child: AnimatedContainer(
                              duration: NexoMotion.normal,
                              decoration: BoxDecoration(
                                color: NexoColors.indigo
                                    .withOpacity(0.08 + intensity * 0.62),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: value > 0
                                  ? Text(
                                      '$value',
                                      style: TextStyle(
                                        fontSize: NexoText.xs,
                                        fontWeight: FontWeight.w700,
                                        color: intensity > 0.5
                                            ? Colors.white
                                            : NexoColors.indigo,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.maxValue});
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Menos', style: TextStyle(fontSize: NexoText.xs, color: fgMuted)),
        const SizedBox(width: 8),
        ...List.generate(5, (i) {
          final intensity = i / 4;
          return Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: NexoColors.indigo.withOpacity(0.08 + intensity * 0.62),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text('Mais', style: TextStyle(fontSize: NexoText.xs, color: fgMuted)),
      ],
    );
  }
}

class _EmptyHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const Icon(LucideIcons.brainCircuit, size: 32, color: NexoColors.indigo),
          const SizedBox(height: NexoSpace.md),
          Text(
            'Sem dados pra mostrar ainda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: fgMuted),
          ),
        ],
      ),
    );
  }
}
