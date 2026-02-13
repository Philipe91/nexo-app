import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;        // Mantido para compatibilidade, mas ignorado no novo design
  final double opacity;     // Mantido para compatibilidade
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 0.0,
    this.opacity = 1.0,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final radius = borderRadius ?? BorderRadius.circular(24);
    
    // Cor de fundo: Branco (light) ou Surface Escura (dark)
    final backgroundColor = color ?? (isDark ? theme.colorScheme.surface : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        // Sombra suave e colorida (Moon Heart style)
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : const Color(0xFF4E5AE8).withOpacity(0.08), // Sombra azulada bem leve
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: child, // O child já vem com padding na maioria dos casos ou é ajustado pelo pai
        ),
      ),
    );
  }
}