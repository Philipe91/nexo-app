import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart'; // Para gráficos
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/task_model.dart';
import '../../core/models/member_model.dart';
import '../../core/widgets/glass_card.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();
    
    final members = memberProvider.members;
    final totalLoad = taskProvider.totalMentalLoad;

    // Calcula carga por membro
    Map<String, int> loadPerMember = {};
    for (var m in members) {
      loadPerMember[m.id] = taskProvider.getMemberMentalLoad(m.id);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("Check-in Semanal", style: GoogleFonts.fredoka(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. PLACAR DA CARGA MENTAL
            Text("Como foi a semana?", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (totalLoad > 0 ? totalLoad : 10).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() < members.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(members[value.toInt()].name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    final load = loadPerMember[member.id] ?? 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: load.toDouble(),
                          color: Color(int.parse(member.color)),
                          width: 30,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (totalLoad > 0 ? totalLoad : 10).toDouble(),
                            color: Colors.grey[200],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 2. MESA DE NEGOCIAÇÃO
            Text("Reequilibrar Tarefas", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text("Toque em uma tarefa para transferir.", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),

            ...members.map((member) {
              final memberTasks = taskProvider.tasks.where((t) => t.whoExecutes.contains(member.id)).toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: Color(int.parse(member.color)), radius: 6),
                        const SizedBox(width: 8),
                        Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Text("${loadPerMember[member.id]} pts", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: memberTasks.isEmpty 
                      ? [const Padding(padding: EdgeInsets.all(16), child: Text("Sem tarefas", style: TextStyle(color: Colors.grey)))]
                      : memberTasks.map((task) {
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text("Esforço: ${'⚡' * task.effort}"),
                          trailing: const Icon(Icons.swap_horiz, color: Colors.grey),
                          onTap: () => _showReassignDialog(context, task, members),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            const SizedBox(height: 40),

            // 3. BOTÃO DE FECHAMENTO
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semana fechada! Bom trabalho equipe! 🚀"), backgroundColor: Colors.green),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Fechar Semana e Celebrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showReassignDialog(BuildContext context, Task task, List<Member> members) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Transferir '${task.title}' para:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...members.map((m) {
                if (task.whoExecutes.contains(m.id)) return const SizedBox.shrink(); // Não mostrar quem já faz
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Color(int.parse(m.color)), child: Text(m.name[0], style: const TextStyle(color: Colors.white))),
                  title: Text(m.name),
                  onTap: () {
                    context.read<TaskProvider>().reassignTask(task.id, m.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}