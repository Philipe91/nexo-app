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
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF4E5AE8)), // Azul Moon Heart
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'NEXO', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: Colors.white, // Branco para contrastar com o Header Azul
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
      body: Column(
        children: [
          // Header Curvo com Gradiente
          Container(
            height: 280, // Altura suficiente para AppBar + Status
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Stack(
              children: [
                // Decoração de Bolhas sutis
                Positioned(top: -50, left: -50, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1))),
                Positioned(bottom: 20, right: -20, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
                
                // Conteúdo do Header (Status)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0), // Espaço para AppBar
                    child: GlassCard(
                      color: Colors.white,
                      opacity: 0.85, // Um pouco mais translúcido para o efeito glass
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("CARGA MENTAL", 
                                  style: TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.grey.shade500,
                                    letterSpacing: 1.0
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text(statusText, 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    color: statusColor
                                  )
                                ),
                              ],
                            ),
                            // Indicador Circular
                            SizedBox(
                              height: 60, width: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: totalLoad / 100,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation(statusColor),
                                    strokeCap: StrokeCap.round,
                                  ),
                                  Text("${totalLoad.toInt()}", 
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de Ações (Grid)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                Text("O que vamos fazer?", 
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Quadrado
                  children: [
                    _buildGridCard(context, icon: Icons.calendar_month_rounded, color: const Color(0xFF4E5AE8), title: "Planejamento", subtitle: "Semanal", onTap: () => context.push('/planning')),
                    _buildGridCard(context, icon: Icons.sports_esports_rounded, color: Colors.purpleAccent, title: "Modo Filho", subtitle: "Gamificação", onTap: () => context.push('/kid-mode')),
                    _buildGridCard(context, icon: Icons.restaurant_menu_rounded, color: Colors.orange, title: "Refeições", subtitle: "Cardápio", onTap: () => context.push('/meals')),
                    _buildGridCard(context, icon: Icons.bolt_rounded, color: Colors.amber, title: "Check-in", subtitle: "Avaliar", onTap: () => context.push('/checkin')),
                    
                    // Coloquei o Acordos aqui, mas se quiser pode ser outra coisa
                     _buildGridCard(context, icon: Icons.handshake_rounded, color: Colors.pinkAccent, title: "Acordos", subtitle: "Regras", onTap: () => context.push('/agreements')),
                  ],
                ),
                const SizedBox(height: 100), // Espaço para o FAB ou BottomNav não cobrir
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