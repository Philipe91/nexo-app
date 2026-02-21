import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // --- Lógica de Saudação (NOVO) ---
    final hour = DateTime.now().hour;
    String greeting = "Bom dia";
    if (hour >= 12 && hour < 18) {
      greeting = "Boa tarde";
    } else if (hour >= 18) {
      greeting = "Boa noite";
    }
    
    // Usa o membro atual (usuário logado) se disponível
    final currentMember = memberProvider.currentMember;
    final userName = currentMember?.name.split(' ').first ??
        (memberProvider.members.isNotEmpty ? memberProvider.members.first.name.split(' ').first : 'Família');

    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4E5AE8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   const CircleAvatar(
                     backgroundColor: Colors.white,
                     child: Icon(Icons.person, color: Color(0xFF4E5AE8)),
                   ),
                   const SizedBox(height: 12),
                   Text("Menu", style: GoogleFonts.fredoka(fontSize: 24, color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                // Navegar
                context.pop(); // Fecha drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Perfil'),
              onTap: () {
                context.pop();
              },
            ),
             const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre o Nexo'),
              onTap: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      leading: Tooltip(
        message: 'Ver meu perfil',
        child: Semantics(
          label: 'Botão de perfil',
          button: true,
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: currentMember != null
                    ? Color(int.tryParse(currentMember.color) ?? 0xFF4D5BCE)
                    : const Color(0xFF4D5BCE),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'N',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
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
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), // Reduzi topo pois a saudação flutua
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- SAUDAÇÃO (NOVO LOCAL) ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, left: 4),
                          child: Row(
                            children: [
                              Text(
                                "$greeting, ",
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                userName,
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector( // <--- Mudado para GestureDetector
                      onTap: () => context.push('/mental-load-history'), // <--- Navegação adicionada
                      child: GlassCard(
                        color: Colors.white,
                        opacity: 0.95, // Quase sólido para evitar "branco estranho"
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("CARGA MENTAL", 
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.grey.shade600,
                                      letterSpacing: 1.2
                                    )
                                  ),
                                  Text("${totalLoad.toInt()}%", 
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w900, 
                                      color: statusColor
                                    )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(statusText, 
                                style: TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold, 
                                  color: statusColor,
                                  height: 1.2
                                )
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: totalLoad / 100,
                                  minHeight: 16, // Barra robusta
                                  backgroundColor: const Color(0xFFF0F4F8), // Fundo sutil
                                  valueColor: AlwaysStoppedAnimation(statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ], // Closing children list for Column
                ), // Closing Column
              ), // Closing Padding
            ), // Closing SafeArea
          ], // Closing Stack children list
            ),
          ),

          // Lista de Ações (Grid)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // --- WIDGET DO BIO-RITMO (NOVO) ---
                if (memberProvider.members.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      // Pega o primeiro membro mulher/adulto como referência ou o que tiver ciclo cadastrado
                      final cycleProvider = context.watch<CycleProvider>();
                      final memberId = memberProvider.members.first.id; // Simplificação: Pega o primeiro
                      final cycleInfo = cycleProvider.getCurrentPhaseInfo(memberId);

                      if (cycleInfo['hasData'] == true) {
                        final Color phaseColor = cycleInfo['color'] as Color;
                        final String phaseName = cycleInfo['phase'] as String;
                        final IconData phaseIcon = cycleInfo['icon'] as IconData;
                        final String tip = cycleInfo['tip'] as String;
                        final int currentDay = cycleInfo['day'] as int;
                        // Assumindo ciclo de 28 dias para a barra de progresso (poderia vir do provider)
                        final double progress = (currentDay / 28).clamp(0.0, 1.0);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            // Gradiente Sutil de Fundo
                            gradient: LinearGradient(
                              colors: [Colors.white, phaseColor.withOpacity(0.15)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28), // Mais arredondado
                            boxShadow: [
                              BoxShadow(color: phaseColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                            ]
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/cycle-settings'),
                              borderRadius: BorderRadius.circular(28),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Ícone Grande com Fundo
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: phaseColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                                            ]
                                          ),
                                          child: Icon(phaseIcon, color: phaseColor, size: 32),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Infos Principais
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Bio-Ritmo", 
                                                style: GoogleFonts.fredoka(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                phaseName, 
                                                style: GoogleFonts.fredoka(
                                                  fontWeight: FontWeight.w600, 
                                                  fontSize: 20,
                                                  color: Colors.black87
                                                )
                                              ),
                                              const SizedBox(height: 8),
                                              // Barra de Progresso do Ciclo
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: Colors.grey.shade200,
                                                  valueColor: AlwaysStoppedAnimation(phaseColor),
                                                  minHeight: 6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Card de Dica
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: phaseColor.withOpacity(0.1)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.tips_and_updates_outlined, size: 20, color: phaseColor), // Usei tips_and_updates se disponível ou lightbulb
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              tip, 
                                              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade800),
                                            )
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container( // Estado Vazio (Sem Dados)
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade100),
                             boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                               onTap: () => context.push('/cycle-settings'),
                               borderRadius: BorderRadius.circular(24),
                               child: Padding(
                                 padding: const EdgeInsets.all(20),
                                 child: Row(
                                   children: [
                                     Container(
                                       padding: const EdgeInsets.all(12),
                                       decoration: BoxDecoration(
                                         color: Colors.pinkAccent.withOpacity(0.1),
                                         shape: BoxShape.circle,
                                       ),
                                       child: const Icon(Icons.favorite_border, color: Colors.pinkAccent),
                                     ),
                                     const SizedBox(width: 16),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text("Configurar Bio-Ritmo", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 16)),
                                           const SizedBox(height: 4),
                                           Text("Toque para acompanhar o ciclo.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                         ],
                                       ),
                                     ),
                                     const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                                   ],
                                 ),
                               ),
                            ),
                          ),
                        );
                      }
                    }
                  ),
                ],

                Text("O que vamos fazer?", 
                  style: GoogleFonts.fredoka(
                    fontSize: 22, 
                    fontWeight: FontWeight.w600, 
                    color: const Color(0xFF4E5AE8),
                    letterSpacing: 0.5
                  )
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
                     _buildGridCard(context, icon: Icons.bar_chart_rounded, color: Colors.teal, title: "Estatísticas", subtitle: "Relatórios", onTap: () => context.push('/stats')),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)], // Gradiente mais sólido
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Fundo suave para o ícone
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
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