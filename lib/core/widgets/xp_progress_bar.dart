import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int level;
  final double height;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.level,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    // Entendendo a fórmula do provider: Level = 1 + (XP / 1000)
    // Logo, XP do nível atual = (Level - 1) * 1000
    // XP do próximo nível = Level * 1000
    
    final int startLevelXp = (level - 1) * 1000;
    final int nextLevelXp = level * 1000;
    
    final int xpInCurrentLevel = currentXp - startLevelXp;
    final int xpNeededForNextLevel = 1000; // Sempre 1000 por nível nessa fórmula simples

    final double progress = (xpInCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nível $level",
              style: GoogleFonts.fredoka(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            Text(
              "$xpInCurrentLevel / $xpNeededForNextLevel XP",
              style: GoogleFonts.fredoka(
                fontSize: 14, 
                fontWeight: FontWeight.w500, 
                color: Colors.white.withOpacity(0.9)
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Stack(
            children: [
              // Barra de Fundo
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: Colors.amber, // Cor de Ouro/XP
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  );
                },
              ),
              // Brilho/Glitter (Opcional)
            ],
          ),
        ),
      ],
    );
  }
}
