import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';

class ResponsibilitiesScreen extends StatefulWidget {
  const ResponsibilitiesScreen({super.key});

  @override
  State<ResponsibilitiesScreen> createState() => _ResponsibilitiesScreenState();
}

class _ResponsibilitiesScreenState extends State<ResponsibilitiesScreen> {
  // Variável para controlar o filtro (null = mostra todos)
  String? _selectedMemberFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();

    final allTasks = taskProvider.tasks;
    final members = memberProvider.members;

    // Lógica do Filtro: Se tiver alguém selecionado, filtra a lista
    final filteredTasks = _selectedMemberFilter == null
        ? allTasks
        : allTasks.where((task) => 
            task.whoRemembers == _selectedMemberFilter || 
            task.whoDecides == _selectedMemberFilter || 
            task.whoExecutes == _selectedMemberFilter
          ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Todas as Tarefas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/responsibilities/add'),
        label: const Text("Nova Tarefa"),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          // --- ÁREA DE FILTROS ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Botão "Todos"
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text("Todos"),
                    selected: _selectedMemberFilter == null,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedMemberFilter = null;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                // Botões para cada Membro
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
                        setState(() {
                          // Se clicar no que já tá selecionado, tira o filtro
                          _selectedMemberFilter = selected ? member.name : null;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // --- LISTA DE TAREFAS ---
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _selectedMemberFilter == null 
                            ? "Nenhuma tarefa criada." 
                            : "Nenhuma tarefa para ${_selectedMemberFilter}.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      // Inverte a lista para mostrar as novas primeiro, se não tiver filtrando
                      final task = _selectedMemberFilter == null 
                          ? filteredTasks.reversed.toList()[index] 
                          : filteredTasks[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          color: Colors.white,
                          opacity: 0.8,
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _getEffortColor(task.effort).withOpacity(0.1),
                              child: Text(
                                task.effort.toString(), 
                                style: TextStyle(fontWeight: FontWeight.bold, color: _getEffortColor(task.effort))
                              ),
                            ),
                            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${task.frequency} • ${task.whoRemembers} lembra"),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildDetailRow("🧠 Quem Lembra", task.whoRemembers),
                                    const SizedBox(height: 8),
                                    _buildDetailRow("⚖️ Quem Decide", task.whoDecides),
                                    const SizedBox(height: 8),
                                    _buildDetailRow("💪 Quem Executa", task.whoExecutes),
                                    const Divider(height: 24),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          context.read<TaskProvider>().removeTask(task.id);
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        label: const Text("Excluir Tarefa", style: TextStyle(color: Colors.red)),
                                      ),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
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