import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/glass_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();

    final members = memberProvider.members;
    final weeklyStats = taskProvider.calculateWeeklyStats();

    // Encontrar membro com maior pontuação semanal
    String? topPerformerId;
    int maxScore = -1;
    weeklyStats.forEach((id, score) {
      if (score > maxScore) {
        maxScore = score;
        topPerformerId = id;
      }
    });

    final topPerformer = members.firstWhere(
      (m) => m.id == topPerformerId, 
      orElse: () => members.isNotEmpty ? members.first :  members.first
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Balanço Familiar", style: GoogleFonts.fredoka(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Memória da casa (Heatmap) ---
            AppCard(
              onTap: () => context.push('/memory-load'),
              padding: const EdgeInsets.all(NexoSpace.lg),
              glow: NexoColors.indigo,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: NexoColors.indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(NexoRadius.sm),
                      border: Border.all(color: NexoColors.indigo.withOpacity(0.20)),
                    ),
                    child: const Icon(LucideIcons.brainCircuit,
                        color: NexoColors.indigo, size: 22),
                  ),
                  const SizedBox(width: NexoSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Memória da casa',
                            style: GoogleFonts.fredoka(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'Quem mais carrega o peso de lembrar.',
                          style: TextStyle(
                              fontSize: NexoText.sm, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Destaque da Semana ---
            if (maxScore > 0) ...[
              const Text("🏆 Destaque da Semana", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GlassCard(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text("🥇", style: const TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(topPerformer.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("$maxScore tarefas concluídas!", style: const TextStyle(color: Colors.brown)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // --- Carga Mental (Gráfico de Pizza) ---
            const Text("🧠 Distribuição da Carga Mental", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Quem se preocupa com o quê (Lembrar + Decidir + Executar)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 250,
              child: members.isEmpty 
                ? const Center(child: Text("Sem dados"))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: members.map((member) {
                        final load = taskProvider.getMemberMentalLoad(member.id);
                        final color = Color(int.parse(member.color.replaceAll('#', '0xFF')));
                        return PieChartSectionData(
                          color: color,
                          value: load.toDouble(),
                          title: '${load}%',
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
            ),
            
            // Legenda do Gráfico
            Center(
              child: Wrap(
                spacing: 16,
                children: members.map((m) {
                   return Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Container(width: 12, height: 12, color: Color(int.parse(m.color.replaceAll('#', '0xFF'))),),
                       const SizedBox(width: 4),
                       Text(m.name, style: const TextStyle(fontSize: 12)),
                     ],
                   );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // --- Desempenho Semanal (Bar Chart) ---
            const Text("📊 Realizações (7 dias)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxScore + 2).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < members.length) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(members[value.toInt()].name.substring(0, 3), style: const TextStyle(fontSize: 12)),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: members.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    final score = weeklyStats[member.id] ?? 0;
                    final color = Color(int.parse(member.color.replaceAll('#', '0xFF')));

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: score.toDouble(),
                          color: color,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (maxScore + 2).toDouble(),
                            color: Colors.grey.shade200,
                          ), 
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
