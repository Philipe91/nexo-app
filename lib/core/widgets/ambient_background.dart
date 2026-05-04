import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Background ambiente — 2 a 3 "blobs" desfocados oscilando lentamente.
/// Cria sensação cinematográfica sem custo alto: usa Transforms simples,
/// não BackdropFilter (caro no web).
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.colors,
    this.intensity = 1.0,
  });

  final Widget child;
  final List<Color>? colors;
  final double intensity;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.colors ??
        (dark
            ? const [NexoColors.indigo, NexoColors.indigoSoft, Color(0xFF8B5CF6)]
            : const [NexoColors.indigoSoft, Color(0xFFA78BFA), Color(0xFFFFD1DC)]);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: dark ? NexoColors.darkBg : NexoColors.lightBg),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = _ctrl.value * 2 * math.pi;
              return Stack(
                children: [
                  _Blob(
                    color: base[0].withOpacity(dark ? 0.30 : 0.22),
                    size: 360,
                    align: Alignment(
                      math.sin(t) * 0.6,
                      -0.6 + math.cos(t * 0.7) * 0.2,
                    ),
                    intensity: widget.intensity,
                  ),
                  _Blob(
                    color: base[1].withOpacity(dark ? 0.25 : 0.18),
                    size: 320,
                    align: Alignment(
                      0.7 + math.cos(t * 0.9) * 0.15,
                      math.sin(t * 1.1) * 0.4,
                    ),
                    intensity: widget.intensity,
                  ),
                  if (base.length > 2)
                    _Blob(
                      color: base[2].withOpacity(dark ? 0.18 : 0.14),
                      size: 280,
                      align: Alignment(
                        -0.7 + math.sin(t * 0.5) * 0.2,
                        0.7 + math.cos(t * 0.6) * 0.2,
                      ),
                      intensity: widget.intensity,
                    ),
                ],
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.size,
    required this.align,
    required this.intensity,
  });

  final Color color;
  final double size;
  final Alignment align;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: IgnorePointer(
        child: Container(
          width: size * intensity,
          height: size * intensity,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0)],
              stops: const [0, 1],
            ),
          ),
        ),
      ),
    );
  }
}
