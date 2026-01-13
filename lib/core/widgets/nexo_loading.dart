import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NexoLoading extends StatelessWidget {
  final String message;

  const NexoLoading({super.key, this.message = "Sincronizando..."});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Ou a cor de fundo do seu tema
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo ou Ícone do App pulsando
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.grid_view_rounded, // Pode trocar pela sua logo (ex: Image.asset)
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.1, duration: 800.ms), // Pulsação

          const SizedBox(height: 32),

          // Indicador de Progresso (Rodinha)
          const CircularProgressIndicator(),

          const SizedBox(height: 24),

          // Mensagem
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ).animate().fade().slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }
}
