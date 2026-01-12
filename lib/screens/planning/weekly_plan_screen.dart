import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../core/widgets/glass_card.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mapeamento de dias para facilitar
  final List<String> _days = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom", "Flex"];

  @override
  void initState() {
    super.initState();
    // 7 dias da semana + 1 aba para tarefas Flexíveis = 8 abas
    _tabController = TabController(length: 8, vsync: this);
    
    // Tenta abrir a aba do dia atual (Segunda=1 ... Domingo=7)
    // DateTime.weekday retorna 1 para Seg, 7 para Dom.
    // O index do TabController começa em 0. Então: dia - 1.
    int currentDayIndex = DateTime.now().weekday - 1; 
    _tabController.index = currentDayIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Planejamento Semanal"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Permite rolar se a tela for pequena
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: TabBarView(
          controller: _tabController,
          children: List.generate(8, (index) {
            // Lógica de Filtro:
            // Index 0 a 6 = Dias da semana (1 a 7 no modelo)
            // Index 7 = Flexível (null no modelo)
            
            final targetWeekDay = index < 7 ? index + 1 : null;
            
            final tasksForDay = allTasks.where((t) {
              return t.weekDay == targetWeekDay;
            }).toList();

            return _buildDayList(tasksForDay, index);
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/responsibilities/add'),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayList(List<Task> tasks, int index) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Nada planejado para ${_days[index]}.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            color: Colors.white,
            opacity: 1.0,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getEffortColor(task.effort).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(task.effort), 
                  color: _getEffortColor(task.effort),
                  size: 20,
                ),
              ),
              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${task.whoExecutes} executa • ${task.frequency}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                onPressed: () => context.push('/responsibilities/add', extra: task),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getEffortColor(int effort) {
    if (effort == 1) return Colors.green;
    if (effort == 2) return Colors.orange;
    return Colors.red;
  }

  IconData _getCategoryIcon(int effort) {
    if (effort == 1) return Icons.sentiment_satisfied_alt;
    if (effort == 2) return Icons.sentiment_neutral;
    return Icons.whatshot;
  }
}