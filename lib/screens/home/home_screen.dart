import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_drawer.dart'; // <--- Import do Drawer Novo

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final totalLoad = taskProvider.totalMentalLoad;

    // Definição de Cores do Status
    String statusText = "Equilibrada";
    Color statusColor = Colors.green;
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
      drawer: const AppDrawer(), // <--- AQUI ESTÁ O DRAWER
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ícone do Menu (Avatar do Usuário)
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Text('NEXO',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
              letterSpacing: 2,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          // --- FUNDO AMBIENTE ---
          Positioned(
            top: -100,
            left: -50,
            child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blue.shade50))
                .blur(60),
          ),
          Positioned(
            top: 100,
            right: -50,
            child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.purple.shade50))
                .blur(60),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                const SizedBox(height: 10),

                // 1. CARD DE STATUS (O Coração do Dashboard)
                GlassCard(
                  opacity: 0.9,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Carga Mental',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Text(statusText,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: statusColor)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_graph,
                                      size: 16, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text('$totalLoad pts',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Barra de Progresso Bonita
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey.shade100),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double percent = (totalLoad / 40).clamp(0.0, 1.0);
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: constraints.maxWidth * percent,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: LinearGradient(
                                        colors: [gradientStart, gradientEnd]),
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

                const SizedBox(height: 32),

                // 2. GRID DE AÇÕES (MODERNO E LIMPO)
                const Text("Acesso Rápido",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1, // Quadrados um pouco mais largos
                  children: [
                    _buildGridCard(context,
                        icon: Icons.calendar_month_rounded,
                        color: Colors.blue,
                        title: "Planejamento",
                        subtitle: "Semanal",
                        onTap: () => context.push('/planning')),
                    _buildGridCard(context,
                        icon: Icons.sports_esports_rounded,
                        color: Colors.purple,
                        title: "Modo Filho",
                        subtitle: "Gamificação",
                        onTap: () => context.push('/kid-mode')),
                    _buildGridCard(context,
                        icon: Icons.bolt_rounded,
                        color: Colors.orange,
                        title: "Check-in",
                        subtitle: "Avaliar Semana",
                        onTap: () => context.push('/checkin')),
                    _buildGridCard(context,
                        icon: Icons.handshake_rounded,
                        color: Colors.pink,
                        title: "Acordos",
                        subtitle: "Regras da Casa",
                        onTap: () => context.push('/agreements')),
                  ],
                ),

                const SizedBox(height: 32),

                // 3. TAREFAS RÁPIDAS (Botão Gigante)
                InkWell(
                  onTap: () => context.push('/responsibilities'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: Icon(Icons.list_alt_rounded,
                              color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Lista de Tarefas",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text("Ver todas as responsabilidades",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        // Botão de Adicionar Rápido
                        IconButton(
                          onPressed: () =>
                              context.push('/responsibilities/add'),
                          icon: Container(
                            decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return GlassCard(
      onTap: onTap,
      color: Colors.white,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            )
          ],
        ),
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
