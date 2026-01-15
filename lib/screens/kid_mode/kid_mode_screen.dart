import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/member_model.dart';
import '../../models/task_model.dart';
import '../../core/widgets/glass_card.dart';

class KidModeScreen extends StatefulWidget {
  const KidModeScreen({super.key});

  @override
  State<KidModeScreen> createState() => _KidModeScreenState();
}

class _KidModeScreenState extends State<KidModeScreen> {
  Member? _selectedKid;

  // Dias da semana para cabeçalho
  final List<String> weekDays = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];

  // Pega o dia de hoje (Ex: "Seg")
  String get _todayCode {
    final now = DateTime.now();
    final dayNum = now.weekday; // 1 = Seg
    if (dayNum >= 1 && dayNum <= 7) return weekDays[dayNum - 1];
    return "Seg";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Fundo clarinho
      body: SafeArea(
        child: Column(
          children: [
            // --- Cabeçalho Divertido ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 32),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text(
                    "Modo Criança",
                    style: GoogleFonts.fredoka( // Fonte mais divertida se tiver
                      fontSize: 28, 
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Equilibra o ícone de voltar
                ],
              ),
            ),

            // --- Seleção da Criança ---
            if (_selectedKid == null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Quem é você?", 
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: members.map((member) {
                          // Tratamento de cor seguro
                          Color color;
                          try {
                            color = Color(int.parse(member.color));
                          } catch (e) {
                            color = Colors.blue;
                          }

                          return GestureDetector(
                            onTap: () => setState(() => _selectedKid = member),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                                    ]
                                  ),
                                  child: Center(
                                    child: Text(
                                      member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                                const SizedBox(height: 12),
                                Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              )
            ] else ...[
              // --- Área de Tarefas da Criança ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(int.parse(_selectedKid!.color)),
                      child: Text(_selectedKid!.name[0], style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Oi, ${_selectedKid!.name}!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Suas missões de hoje ($_todayCode):", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _selectedKid = null),
                      child: const Text("Trocar"),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: _buildKidTasks(taskProvider),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKidTasks(TaskProvider provider) {
    // Filtra tarefas que:
    // 1. O 'whoExecutes' é a criança selecionada
    // 2. A tarefa está marcada para o dia de hoje (contains _todayCode)
    final myTasks = provider.tasks.where((t) {
      return t.whoExecutes == _selectedKid!.name && 
             t.days.contains(_todayCode);
    }).toList();

    if (myTasks.isEmpty) {
      return [
        const SizedBox(height: 50),
        const Icon(Icons.star_rounded, size: 100, color: Colors.amber),
        const SizedBox(height: 20),
        const Text(
          "Uau! Tudo livre hoje!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ];
    }

    return myTasks.map((task) {
      // Verifica se já foi feita hoje
      final isDone = _isCompletedToday(task);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          color: Colors.white,
          opacity: 1.0,
          onTap: () {
            // CORREÇÃO AQUI: Passamos 'task.id' em vez de 'task'
            provider.toggleTaskCompletion(task.id); 
            
            if (!isDone) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✨ Mandou bem! +XP Ganho!"), backgroundColor: Colors.amber),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Checkbox Gigante
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: isDone ? Colors.green : Colors.grey.shade400, width: 3),
                  ),
                  child: isDone 
                    ? const Icon(Icons.check, color: Colors.white, size: 32)
                    : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : Colors.black87
                        ),
                      ),
                      Text(
                        "${task.effort} Pontos de Energia",
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (isDone) 
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 32)
                      .animate().scale(curve: Curves.elasticOut),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  bool _isCompletedToday(Task task) {
    if (task.lastCompletedDate == null) return false;
    final now = DateTime.now();
    final last = task.lastCompletedDate!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }
}