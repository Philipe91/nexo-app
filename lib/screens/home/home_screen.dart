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
    
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();
    
    final totalLoad = taskProvider.totalMentalLoad;
    final members = memberProvider.members;

    String statusText = "Equilibrada";
    Color statusColor = Colors.green; // Verde Suave
    Color gradientStart = const Color(0xFF43cea2);
    Color gradientEnd = const Color(0xFF185a9d);
    
    if (totalLoad > 10) {
      statusText = "Movimentada";
      statusColor = Colors.orange;
      gradientStart = const Color(0xFFf83600);
      gradientEnd = const Color(0xFFfe8c00);
    }
    if (totalLoad > 20) {
      statusText = "Sobrecarregada";
      statusColor = Colors.red;
      gradientStart = const Color(0xFFcb2d3e);
      gradientEnd = const Color(0xFFef473a);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, Família 👋', 
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey.shade600, 
                  fontWeight: FontWeight.normal
                )
              ),
              Text(
                'NEXO', 
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900, 
                  color: theme.colorScheme.primary,
                  letterSpacing: -1,
                )
              ),
            ],
          ),
        ),
        actions: [
          // --- 1. BOTÃO CHECK-IN MODERNO (GRADIENTE) ---
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => context.push('/checkin'),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Check-in", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // --- 2. BOTÃO SETTINGS (ESTILO PERFIL) ---
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => context.push('/settings'),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
              ),
            ),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                const SizedBox(height: 10),
                
                // 1. CARD DE STATUS GERAL (COM GRADIENTE SUTIL)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status da Casa', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      statusText,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: statusColor),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.auto_graph_rounded, color: statusColor),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '$totalLoad Pontos de Carga Total',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            // Barra de progresso com gradiente
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey.shade200,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double percent = (totalLoad / 30).clamp(0.0, 1.0);
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: constraints.maxWidth * percent,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 2. EQUILÍBRIO DA CASA
                if (members.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text("Equilíbrio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text("${members.length} membros", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista Horizontal de Membros (Mais moderna)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final stats = taskProvider.calculateMentalLoad(member.name);
                        final memberLoad = stats['total'] ?? 0;
                        
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                child: Text(member.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              ),
                              const SizedBox(height: 8),
                              Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                              Text("$memberLoad pts", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                
                // 3. ACESSO RÁPIDO (Botões Grandes)
                const Text("O que vamos fazer?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context, 
                        icon: Icons.add_circle_outline, 
                        label: "Nova Tarefa", 
                        color: theme.colorScheme.primary, 
                        isPrimary: true,
                        onTap: () => context.push('/responsibilities/add'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        context, 
                        icon: Icons.group_outlined, 
                        label: "Membros", 
                        color: theme.colorScheme.secondary, 
                        isPrimary: false,
                        onTap: () => context.push('/members'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                GlassCard(
                  onTap: () => context.push('/agreements'),
                  color: Colors.white,
                  opacity: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.handshake_outlined, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Acordos da Casa", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Regras e combinados", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                // 4. RECENTES
                if (taskProvider.tasks.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () => context.push('/responsibilities'),
                        child: Text("Ver tudo", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...taskProvider.tasks.reversed.take(5).map((task) => Padding( 
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      opacity: 0.8, // Mais opacidade para leitura
                      color: Colors.white,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getEffortColor(task.effort).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.effort.toString(), 
                            style: TextStyle(fontWeight: FontWeight.w900, color: _getEffortColor(task.effort), fontSize: 16)
                          ),
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          "${task.whoRemembers} lembra • ${task.frequency}",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        trailing: Icon(Icons.more_vert, color: Colors.grey.shade400),
                        onTap: () => context.push('/responsibilities/add', extra: task), // Atalho para editar ao clicar
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

  // Widget auxiliar para botões bonitos
  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required Color color, required bool isPrimary, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? color.withOpacity(0.4) : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isPrimary ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
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