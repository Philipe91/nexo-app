import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({super.key, required this.newLevel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40), // Espaço para o ícone
                Text(
                  "PARABÉNS!",
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                  ),
                ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 16),
                
                Text(
                  "Você chegou ao",
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
                ),
                
                Text(
                  "NÍVEL $newLevel",
                  style: GoogleFonts.fredoka(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ).animate().shimmer(delay: 600.ms, duration: 1000.ms),

                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text("CONTINUAR"),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),

          // Ícone Flutuante no Topo
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, size: 64, color: Colors.white),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).then().shake(),
          ),
        ],
      ),
    );
  }
}
