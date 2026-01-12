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
    this.blur = 10.0,
    this.opacity = 0.1, // Opacidade padrão
    this.color,         // Se null, vamos decidir baseado no tema
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Define a cor base automaticamente se não for passada
    final baseColor = color ?? (isDark ? Colors.black : Colors.white);
    
    // Ajusta a borda para ser sutil em ambos os modos
    final borderColor = isDark 
        ? Colors.white.withOpacity(0.05) 
        : Colors.white.withOpacity(0.4);

    final radius = borderRadius ?? BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              decoration: BoxDecoration(
                // Usa a cor base com a opacidade definida
                color: baseColor.withOpacity(isDark ? 0.6 : 0.7), 
                borderRadius: radius,
                border: Border.all(
                  color: borderColor,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    spreadRadius: -2,
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