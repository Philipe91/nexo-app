import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/task_provider.dart';
import '../../core/widgets/glass_card.dart';

class WeeklyPlanningScreen extends StatefulWidget {
  const WeeklyPlanningScreen({super.key});

  @override
  State<WeeklyPlanningScreen> createState() => _WeeklyPlanningScreenState();
}

class _WeeklyPlanningScreenState extends State<WeeklyPlanningScreen> {
  // Dias da semana mapeados (para bater com o que salvamos no TaskModel)
  final List<String> weekDays = [
    "Seg",
    "Ter",
    "Qua",
    "Qui",
    "Sex",
    "Sáb",
    "Dom"
  ];

  late String _selectedDay;

  @override
  void initState() {
    super.initState();
    // Tenta identificar o dia de hoje para abrir focado nele
    _setToday();
  }

  void _setToday() {
    // intl: EEE devolve 'Mon', 'Tue'... precisamos converter para 'Seg', 'Ter'
    final now = DateTime.now();
    final dayNum = now.weekday; // 1 = Seg, 7 = Dom

    // Mapeando DateTime.weekday (1..7) para nosso array (0..6)
    if (dayNum >= 1 && dayNum <= 7) {
      _selectedDay = weekDays[dayNum - 1];
    } else {
      _selectedDay = "Seg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();

    // Filtra tarefas do dia selecionado
    final tasksForDay = taskProvider.getTasksForDay(_selectedDay);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Planejamento Semanal"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Fundo Suave
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Sua rotina",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text("Toque nos dias para ver a agenda.",
                      style: TextStyle(color: Colors.grey)),
                ),

                const SizedBox(height: 24),

                // --- SELETOR DE DIAS (CALENDÁRIO HORIZONTAL) ---
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: weekDays.length,
                    itemBuilder: (context, index) {
                      final day = weekDays[index];
                      final isSelected = day == _selectedDay;

                      // Conta quantas tarefas tem nesse dia para mostrar uma bolinha
                      final count = taskProvider.getTasksForDay(day).length;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 65,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                            border: isSelected
                                ? null
                                : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(day,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              if (count > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : theme.colorScheme.primary
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text("$count",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : theme.colorScheme.primary)),
                                )
                              else
                                Icon(Icons.remove,
                                    size: 10,
                                    color: isSelected
                                        ? Colors.white54
                                        : Colors.grey.shade300)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // --- LISTA DE TAREFAS DO DIA ---
                Expanded(
                  child: tasksForDay.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.weekend_outlined,
                                  size: 64, color: Colors.blue.shade100),
                              const SizedBox(height: 16),
                              Text("Nada planejado para $_selectedDay!",
                                  style:
                                      TextStyle(color: Colors.grey.shade500)),
                              TextButton(
                                onPressed: () =>
                                    context.push('/responsibilities/add'),
                                child: const Text("Criar uma tarefa"),
                              )
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: tasksForDay.length,
                          itemBuilder: (context, index) {
                            final task = tasksForDay[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                color: Colors.white,
                                opacity: 0.9,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getEffortColor(task.effort)
                                            .withOpacity(0.1),
                                    child: Icon(
                                      _getIconForTask(task.frequency),
                                      color: _getEffortColor(task.effort),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(task.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    "${task.whoExecutes} executa",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () => context.push(
                                        '/responsibilities/add',
                                        extra: task),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getEffortColor(int effort) {
    if (effort == 1) return Colors.green;
    if (effort == 2) return Colors.orange;
    return Colors.red;
  }

  IconData _getIconForTask(String freq) {
    if (freq == 'Diário') return Icons.repeat;
    return Icons.event_available;
  }
}
