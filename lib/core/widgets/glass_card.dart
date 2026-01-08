import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,            // O quanto embaça o fundo
    this.opacity = 0.1,          // Transparência do vidro (10%)
    this.color = Colors.white,   // Cor do vidro
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Bordas arredondadas padrão se não for passado nada
    final radius = borderRadius ?? BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), // O desfoque mágico
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              decoration: BoxDecoration(
                color: color!.withOpacity(opacity), // Fundo translúcido
                borderRadius: radius,
                border: Border.all(
                  // Borda fina brilhante para dar o efeito de "borda de vidro"
                  color: Colors.white.withOpacity(0.1), 
                  width: 1.0,
                ),
                // Sombra suave para destacar do fundo
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: -5,
                  )
                ]
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}