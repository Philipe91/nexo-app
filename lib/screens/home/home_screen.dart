import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // "Escuta" o cérebro. Se mudar algo lá, essa tela redesenha sozinha!
    final taskProvider = context.watch<TaskProvider>();
    final totalLoad = taskProvider.totalMentalLoad;

    // Lógica simples para definir o status da casa
    String statusText = "Equilibrada";
    Color statusColor = Colors.green;
    double progressValue = 0.3;

    if (totalLoad > 5) {
      statusText = "Moderada";
      statusColor = Colors.orange;
      progressValue = 0.6;
    }
    if (totalLoad > 10) {
      statusText = "Sobrecarregada";
      statusColor = Colors.red;
      progressValue = 0.9;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('NEXO', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), color: Colors.black87, onPressed: () {}),
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
                
                // 1. CARD DE CARGA MENTAL (Dinâmico)
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
                        const SizedBox(height: 16),
                        Text('Carga Mental', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const SizedBox(height: 4),
                        // Texto que muda conforme os dados
                        Text(
                          statusText,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalLoad Pontos de Esforço', // Mostra o número real
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(statusColor),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Text("Acesso Rápido", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // 2. BOTÕES DE AÇÃO
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
                        // LIGAMOS O BOTÃO AQUI:
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
                
                // 3. LISTA DE TAREFAS
                if (taskProvider.tasks.isNotEmpty) ...[
                  const Text("Tarefas Recentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ...taskProvider.tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      opacity: 0.5,
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(task.effort.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
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
}

extension BlurEffect on Container {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}