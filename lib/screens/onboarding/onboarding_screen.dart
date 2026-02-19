import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
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
      "title": "Carga Mental Invisível?",
      "subtitle": "VOCÊ NÃO ESTÁ SOZINHA(O)",
      "description": "O NEXO equilibra a balança da casa. Organizamos quem Lembra, quem Decide e quem Executa.",
      "icon": Icons.balance_rounded,
    },
    {
      "title": "Método L.D.E.",
      "subtitle": "UMA TAREFA TEM 3 DONOS",
      "description": "Não basta apenas Executar.\nO peso mental de Lembrar e Decidir também conta pontos aqui.",
      "icon": Icons.psychology_rounded, 
    },
    {
      "title": "Sua Mente Livre",
      "subtitle": "DEIXE O APP LEMBRAR",
      "description": "Nós avisamos você na hora certa. Foque no que importa e deixe a memória com a gente.",
      "icon": Icons.notifications_active_rounded,
    },
  ];

  Future<void> _finishOnboarding() async {
    // Salva que o usuário já viu a intro
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    
    if (mounted) {
      context.go('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // --- FUNDO GRADIENTE ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)], // Cores do App
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // --- PADRÃO DE FUNDO (OPCIONAL) ---
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // PAGINAÇÃO
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      // Conteúdo da Página
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ícone em Destaque (Glassmorphism)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    )
                                  ]
                                ),
                                child: Icon(
                                  page['icon'],
                                  size: 80,
                                  color: Colors.white,
                                ),
                              )
                              .animate()
                              .scale(duration: 600.ms, curve: Curves.easeOutBack)
                              .then()
                              .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.5)),
                            ),

                            const SizedBox(height: 60),

                            // Subtítulo
                            Text(
                              (page['subtitle'] as String).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 2.0,
                              ),
                            )
                            .animate()
                            .fade(duration: 500.ms)
                            .slideX(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),

                            const SizedBox(height: 12),

                            // Título
                            Text(
                              page['title'],
                              style: GoogleFonts.outfit(
                                fontSize: 40,
                                height: 1.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                            .animate()
                            .fade(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms),

                            const SizedBox(height: 24),

                            // Descrição
                            Text(
                              page['description'],
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.9),
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

                // BARRA INFERIOR
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicadores de Progresso
                      Row(
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 6,
                            width: _currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      // Botão de Avançar
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == _pages.length - 1) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1 ? "COMEÇAR" : "PRÓXIMO",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF4E5AE8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: const Color(0xFF4E5AE8),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ).animate(target: _currentPage == _pages.length - 1 ? 1 : 0)
                       .scaleXY(end: 1.05, duration: 300.ms) 
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