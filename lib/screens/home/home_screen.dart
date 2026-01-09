import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // "Escuta" os dois cérebros: Tarefas e Membros
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();
    
    final totalLoad = taskProvider.totalMentalLoad;
    final members = memberProvider.members;

    // Lógica simples para definir o status da casa (Geral)
    String statusText = "Equilibrada";
    Color statusColor = Colors.green;
    
    if (totalLoad > 10) {
      statusText = "Movimentada";
      statusColor = Colors.orange;
    }
    if (totalLoad > 20) {
      statusText = "Sobrecarregada";
      statusColor = Colors.red;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('NEXO', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        actions: [
          // --- BOTÃO DE CHECK-IN (NOVO) ---
          TextButton.icon(
            onPressed: () => context.push('/checkin'),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text("Check-in"),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // --- FUNDO (Ambient Light) ---
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade100.withOpacity(0.5)),
            ).blur(80),
          ),
          Positioned(
            top: 100, left: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade100.withOpacity(0.5)),
            ).blur(60),
          ),
          
          // --- CONTEÚDO ---
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                
                // 1. CARD DE STATUS GERAL
                GlassCard(
                  opacity: 0.6,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: statusColor),
                            const SizedBox(width: 8),
                            Text('Status da Casa', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusText,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                        Text(
                          '$totalLoad Pontos de Carga Total',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. EQUILÍBRIO DA CASA
                if (members.isNotEmpty) ...[
                  const Text("Equilíbrio da Carga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...members.map((member) {
                    final stats = taskProvider.calculateMentalLoad(member.name);
                    final memberLoad = stats['total'] ?? 0;
                    
                    Color loadColor = Colors.green;
                    if (memberLoad > 5) loadColor = Colors.orange;
                    if (memberLoad > 10) loadColor = Colors.red;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GlassCard(
                        opacity: 0.4,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                child: Text(member.name[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text("$memberLoad pts", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: memberLoad > 0 ? (memberLoad / 15).clamp(0.0, 1.0) : 0, 
                                      backgroundColor: Colors.grey.shade200,
                                      color: loadColor,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 32),
                
                // 3. BOTÕES DE AÇÃO RÁPIDA
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        onTap: () => context.push('/responsibilities/add'),
                        color: theme.colorScheme.primary,
                        opacity: 0.9,
                        child: const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.add_task, color: Colors.white, size: 32),
                              SizedBox(height: 12),
                              Text("Nova Tarefa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        onTap: () => context.push('/members'),
                        color: Colors.white,
                        opacity: 0.7,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, color: theme.colorScheme.primary, size: 32),
                              const SizedBox(height: 12),
                              Text("Membros", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                
                // 4. LISTA DE TAREFAS
                if (taskProvider.tasks.isNotEmpty) ...[
                  const Text("Tarefas Recentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ...taskProvider.tasks.reversed.take(5).map((task) => Padding( 
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      opacity: 0.5,
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEffortColor(task.effort).withOpacity(0.1),
                          child: Text(task.effort.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: _getEffortColor(task.effort))),
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${task.whoRemembers} lembra • ${task.frequency}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            context.read<TaskProvider>().removeTask(task.id);
                          },
                        ),
                      ),
                    ),
                  )).toList(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEffortColor(int effort) {
    if (effort == 1) return Colors.green;
    if (effort == 2) return Colors.orange;
    return Colors.red;
  }
}

extension BlurEffect on Container {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}