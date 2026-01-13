import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart'; // <--- A MÁGICA
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // DADOS DAS TELAS
  final List<Map<String, dynamic>> _pages = [
    {
      "title": "O fim da\nCarga Mental",
      "subtitle": "Você sente que gerencia a casa sozinho(a)?",
      "description": "O NEXO veio para tornar invisível o trabalho de lembrar de tudo. Vamos equilibrar a balança da sua família.",
      "icon": Icons.balance_rounded,
      "color": const Color(0xFF4D5BCE), // Azul Índigo
    },
    {
      "title": "O Método\nL.D.E.",
      "subtitle": "Uma tarefa tem 3 donos",
      "description": "Não basta apenas Executar.\nAlguém teve que Lembrar.\nAlguém teve que Decidir.\nO NEXO divide esses papéis.",
      "icon": Icons.psychology_rounded, // Cérebro
      "color": const Color(0xFFE91E63), // Pink
    },
    {
      "title": "Sua Mente\nLivre",
      "subtitle": "Deixe o celular lembrar",
      "description": "Nós avisamos você na hora certa, 1 hora antes ou 1 dia antes. Foque no que importa, deixe a memória com a gente.",
      "icon": Icons.notifications_active_rounded,
      "color": const Color(0xFF4CAF50), // Verde
    },
  ];

  Future<void> _finishOnboarding() async {
    // Salva que o usuário já viu a intro
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    
    if (mounted) {
      context.go('/login'); // Agora manda para o Login, e não direto para a Home
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentPageData = _pages[_currentPage];
    final Color pageColor = currentPageData['color'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- FUNDO ANIMADO ---
          // Círculo grande no topo mudando de cor
          AnimatedPositioned(
            duration: 800.ms,
            curve: Curves.easeInOutBack,
            top: -size.width * 0.5,
            right: _currentPage.isEven ? -100 : -50,
            child: AnimatedContainer(
              duration: 600.ms,
              width: size.width * 1.5,
              height: size.width * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pageColor.withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      // Usamos ValueKey para reiniciar a animação ao mudar de página
                      return Padding(
                        key: ValueKey(index), 
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- ÍCONE COM EFEITO ---
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (page['color'] as Color).withOpacity(0.1),
                                ),
                                child: Icon(
                                  page['icon'],
                                  size: 80,
                                  color: page['color'],
                                ),
                              )
                              .animate()
                              .scale(duration: 600.ms, curve: Curves.easeOutBack) // Cresce
                              .then()
                              .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.5)), // Brilha
                            ),

                            const SizedBox(height: 60),

                            // --- SUBTÍTULO (Pequeno) ---
                            Text(
                              (page['subtitle'] as String).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: page['color'],
                                letterSpacing: 1.2,
                              ),
                            )
                            .animate()
                            .fade(duration: 500.ms)
                            .slideX(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),

                            const SizedBox(height: 8),

                            // --- TÍTULO (Grande) ---
                            Text(
                              page['title'],
                              style: GoogleFonts.inter(
                                fontSize: 42,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            )
                            .animate()
                            .fade(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms),

                            const SizedBox(height: 24),

                            // --- DESCRIÇÃO ---
                            Text(
                              page['description'],
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                height: 1.5,
                                color: Colors.grey.shade600,
                              ),
                            )
                            .animate()
                            .fade(delay: 400.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- RODAPÉ ---
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bolinhas de progresso
                      Row(
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? pageColor 
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Botão Próximo
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? "COMEÇAR" : "PRÓXIMO",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ).animate(target: _currentPage == _pages.length - 1 ? 1 : 0)
                       .scaleXY(end: 1.1, duration: 300.ms) // Aumenta um pouco no final
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}