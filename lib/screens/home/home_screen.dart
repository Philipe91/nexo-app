import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/cycle_provider.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final cycleProvider = context.watch<CycleProvider>();

    final totalLoad = taskProvider.totalMentalLoad;

    // --- Lógica de Cores do Status ---
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
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        title: Text(
          'NEXO', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: theme.colorScheme.primary,
            letterSpacing: 2,
          )
        ),
        actions: [
          IconButton(
             icon: const Icon(Icons.favorite_outline, color: Colors.pinkAccent),
             onPressed: () => context.push('/cycle-settings'),
             tooltip: "Configurar Bio-Ritmo",
           )
        ],
      ),
      body: Stack(
        children: [
          // Fundo com Gradiente
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE0F7FA), // Cyan Claro
                    Color(0xFFE1BEE7), // Roxo Claro
                    Color(0xFFF3E5F5), // Roxo Mais Claro
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // Bolhas de fundo
          Positioned(
            top: -100, left: -50,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.3))).blur(80),
          ),
          Positioned(
            top: 100, right: -50,
            child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.withOpacity(0.3))).blur(80),
          ),
          
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                const SizedBox(height: 10),
                
                // 1. STATUS GERAL
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
                                Text(statusText.toUpperCase(), 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: statusColor.withOpacity(0.8),
                                    letterSpacing: 1.2
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text("${totalLoad.toInt()} pts", 
                                  style: TextStyle(
                                    fontSize: 32, 
                                    fontWeight: FontWeight.w900, 
                                    color: Colors.blueGrey.shade800
                                  )
                                ),
                              ],
                            ),
                            // Gráfico Circular Simples
                            SizedBox(
                              height: 60, width: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: totalLoad / 100,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(gradientStart),
                                  ),
                                  Icon(Icons.bolt, color: gradientStart)
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 2. AÇÕES RÁPIDAS (Grid)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildGridCard(context, icon: Icons.calendar_month_rounded, color: Colors.blue, title: "Planejamento", subtitle: "Semanal", onTap: () => context.push('/planning')),
                    _buildGridCard(context, icon: Icons.sports_esports_rounded, color: Colors.purple, title: "Modo Filho", subtitle: "Gamificação", onTap: () => context.push('/kid-mode')),
                    // Compras removido daqui pois já está na barra inferior
                    _buildGridCard(context, icon: Icons.restaurant_menu_rounded, color: Colors.orangeAccent, title: "Refeições", subtitle: "Cardápio Semanal", onTap: () => context.push('/meals')),
                    _buildGridCard(context, icon: Icons.bolt_rounded, color: Colors.orange, title: "Check-in", subtitle: "Avaliar Semana", onTap: () => context.push('/checkin')),
                    _buildGridCard(context, icon: Icons.handshake_rounded, color: Colors.pink, title: "Acordos", subtitle: "Regras da Casa", onTap: () => context.push('/agreements')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return GlassCard(
      opacity: 0.5,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

extension on Container {
  Widget blur(double sigma) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}