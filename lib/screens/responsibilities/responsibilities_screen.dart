import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/empty_state.dart'; // <--- Import Novo

class ResponsibilitiesScreen extends StatefulWidget {
  const ResponsibilitiesScreen({super.key});

  @override
  State<ResponsibilitiesScreen> createState() => _ResponsibilitiesScreenState();
}

class _ResponsibilitiesScreenState extends State<ResponsibilitiesScreen> {
  String? _selectedMemberFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();

    final allTasks = taskProvider.tasks;
    final members = memberProvider.members;

    // Filtro
    final filteredTasks = _selectedMemberFilter == null
        ? allTasks
        : allTasks.where((task) => 
            task.whoRemembers == _selectedMemberFilter || 
            task.whoDecides == _selectedMemberFilter || 
            task.whoExecutes == _selectedMemberFilter
          ).toList();

    return Scaffold(
      extendBodyBehindAppBar: true, // Para o gradiente ficar bonito
      appBar: AppBar(
        title: const Text("Todas as Tarefas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/responsibilities/add'),
        label: const Text("Nova Tarefa"),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Stack(
        children: [
          // Fundo suave (opcional, para dar profundidade)
          Container(color: theme.colorScheme.background),
          
          SafeArea(
            child: Column(
              children: [
                // --- FILTROS ---
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: const Text("Todos"),
                          selected: _selectedMemberFilter == null,
                          onSelected: (bool selected) {
                            setState(() => _selectedMemberFilter = null);
                          },
                          backgroundColor: theme.cardColor,
                          checkmarkColor: theme.colorScheme.primary,
                        ),
                      ),
                      ...members.map((member) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(member.name[0], style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)),
                            ),
                            label: Text(member.name),
                            selected: _selectedMemberFilter == member.name,
                            onSelected: (bool selected) {
                              setState(() => _selectedMemberFilter = selected ? member.name : null);
                            },
                            backgroundColor: theme.cardColor,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // --- LISTA ---
                Expanded(
                  child: filteredTasks.isEmpty
                      ? EmptyState(
                          icon: Icons.assignment_outlined,
                          title: _selectedMemberFilter == null 
                              ? "Nenhuma tarefa criada" 
                              : "Folga para $_selectedMemberFilter!",
                          message: _selectedMemberFilter == null
                              ? "Adicione responsabilidades para organizar a casa."
                              : "Essa pessoa não tem tarefas atribuídas ainda.",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                // A cor agora é automática pelo GlassCard novo
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getEffortColor(task.effort).withOpacity(0.1),
                                    child: Text(
                                      task.effort.toString(), 
                                      style: TextStyle(fontWeight: FontWeight.bold, color: _getEffortColor(task.effort))
                                    ),
                                  ),
                                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    "${task.frequency} • ${task.whoRemembers} lembra",
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          _buildDetailRow("🧠 Quem Lembra", task.whoRemembers, theme),
                                          const SizedBox(height: 8),
                                          _buildDetailRow("⚖️ Quem Decide", task.whoDecides, theme),
                                          const SizedBox(height: 8),
                                          _buildDetailRow("💪 Quem Executa", task.whoExecutes, theme),
                                          const Divider(height: 24),
                                          
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () => context.push('/responsibilities/add', extra: task),
                                                icon: const Icon(Icons.edit, size: 20),
                                                label: const Text("Editar"),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () => context.read<TaskProvider>().removeTask(task.id),
                                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                                label: const Text("Excluir", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getEffortColor(int effort) {
    if (effort == 1) return Colors.green;
    if (effort == 2) return Colors.orange;
    return Colors.red;
  }
}