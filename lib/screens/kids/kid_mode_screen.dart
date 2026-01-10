import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/member_model.dart';
import '../../models/task_model.dart';

class KidModeScreen extends StatefulWidget {
  const KidModeScreen({super.key});

  @override
  State<KidModeScreen> createState() => _KidModeScreenState();
}

class _KidModeScreenState extends State<KidModeScreen> {
  Member? _selectedMember;
  final List<String> weekDays = [
    "Seg",
    "Ter",
    "Qua",
    "Qui",
    "Sex",
    "Sáb",
    "Dom"
  ];

  // Pega o código do dia de hoje (Ex: "Seg")
  String get _todayCode {
    final now = DateTime.now();
    final dayNum = now.weekday; // 1 = Seg
    if (dayNum >= 1 && dayNum <= 7) return weekDays[dayNum - 1];
    return "Seg";
  }

  // Verifica se a tarefa está concluída HOJE
  bool _isCompletedToday(Task task) {
    if (task.lastCompletedDate == null) return false;
    final now = DateTime.now();
    final last = task.lastCompletedDate!;
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;
    final taskProvider = context.watch<TaskProvider>();

    // SE NÃO TEM MEMBRO SELECIONADO, MOSTRA A TELA DE ESCOLHA
    if (_selectedMember == null) {
      return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        appBar: AppBar(
          title: const Text("Quem vai brincar?"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.close), onPressed: () => context.pop()),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedMember = member),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(member.name[0],
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    Text(member.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // --- MEMBRO SELECIONADO: MOSTRA TAREFAS ---

    // 1. Pega tarefas de hoje
    final todayTasks = taskProvider.getTasksForDay(_todayCode);
    // 2. Filtra: Só tarefas que essa pessoa executa
    final myTasks = todayTasks
        .where((t) => t.whoExecutes == _selectedMember!.name)
        .toList();
    // 3. Ordena: Pendentes primeiro
    myTasks.sort((a, b) {
      final aDone = _isCompletedToday(a) ? 1 : 0;
      final bDone = _isCompletedToday(b) ? 1 : 0;
      return aDone.compareTo(bDone);
    });

    final totalTasks = myTasks.length;
    final doneTasks = myTasks.where((t) => _isCompletedToday(t)).length;
    final progress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary, // Fundo colorido imersivo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              setState(() => _selectedMember = null), // Volta para seleção
        ),
        title: Row(
          children: [
            const Text("Missões de Hoje",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(_selectedMember!.name[0],
                  style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // --- BARRA DE PROGRESSO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$doneTasks / $totalTasks Concluídas",
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold)),
                    if (progress == 1.0 && totalTasks > 0)
                      const Text("PARABÉNS! 🎉",
                          style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.black12,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE CARTÕES ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: myTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_border,
                              size: 80, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text("Dia de folga!",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(
                              "Nenhuma tarefa para ${_selectedMember!.name} hoje.",
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: myTasks.length,
                      itemBuilder: (context, index) {
                        final task = myTasks[index];
                        final isDone = _isCompletedToday(task);

                        return GestureDetector(
                          onTap: () {
                            context
                                .read<TaskProvider>()
                                .toggleTaskCompletion(task.id);
                            if (!isDone) {
                              // Feedback visual simples
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Boa! Mandou bem, ${_selectedMember!.name}! 🚀"),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  isDone ? Colors.green.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isDone
                                      ? Colors.green.shade200
                                      : Colors.grey.shade200,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: isDone
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                // Checkbox Gigante Customizado
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDone ? Colors.green : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: isDone
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                        width: 3),
                                  ),
                                  child: isDone
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 28)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDone
                                              ? Colors.grey
                                              : Colors.black87,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (isDone)
                                        const Text("Concluída!",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))
                                      else
                                        Text("${task.effort} pts de esforço",
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12)),
                                    ],
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
        ],
      ),
    );
  }
}
