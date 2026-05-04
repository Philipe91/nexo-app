import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Pulso da Família — componente hero da Home.
///
/// Anel circular que pulsa lento mostrando a "saúde" da família como um todo.
/// O anel é dividido em segmentos: cada membro ocupa uma fatia proporcional
/// à sua carga mental atual. A cor do anel inteiro varia do índigo (calmo)
/// → âmbar (movimentado) → vermelho (sobrecarregado).
///
/// Centro mostra o número agregado (% de carga). Tap expande pra detalhe
/// (não implementado aqui — basta passar `onTap`).
class FamilyPulse extends StatefulWidget {
  const FamilyPulse({
    super.key,
    required this.totalLoad,
    required this.segments,
    this.onTap,
    this.size = 220,
    this.label = 'Pulso da Família',
  });

  /// Carga total agregada (0..100).
  final double totalLoad;

  /// Segmentos por membro: cada um com cor + peso (0..1).
  final List<FamilyPulseSegment> segments;

  final VoidCallback? onTap;
  final double size;
  final String label;

  @override
  State<FamilyPulse> createState() => _FamilyPulseState();
}

class FamilyPulseSegment {
  const FamilyPulseSegment({required this.color, required this.weight, required this.label});
  final Color color;
  final double weight;
  final String label;
}

class _FamilyPulseState extends State<FamilyPulse> with TickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _pulse.dispose();
    _enter.dispose();
    super.dispose();
  }

  Color _statusColor() {
    if (widget.totalLoad >= 70) return NexoColors.danger;
    if (widget.totalLoad >= 40) return NexoColors.warning;
    return NexoColors.indigo;
  }

  String _statusLabel() {
    if (widget.totalLoad >= 70) return 'Sobrecarregada';
    if (widget.totalLoad >= 40) return 'Movimentada';
    return 'Equilibrada';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor();
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Semantics(
      label: '${widget.label}: ${_statusLabel()}, ${widget.totalLoad.toInt()}%',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _enter]),
            builder: (_, __) {
              final breath = math.sin(_pulse.value * 2 * math.pi); // -1..1
              final scale = 1.0 + breath * 0.018;
              final glowAmount = 0.5 + (breath + 1) / 4; // 0.5..1.0
              final enterT = Curves.easeOutCubic.transform(_enter.value);

              return Transform.scale(
                scale: scale,
                child: CustomPaint(
                  painter: _PulsePainter(
                    segments: widget.segments,
                    progress: enterT,
                    statusColor: statusColor,
                    glowAmount: glowAmount,
                    isDark: dark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.totalLoad.toInt()}',
                          style: AppTheme.display(
                            size: 56,
                            weight: FontWeight.w800,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'pulso',
                          style: TextStyle(
                            fontSize: NexoText.xs,
                            letterSpacing: 1.4,
                            color: fgMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(NexoRadius.pill),
                          ),
                          child: Text(
                            _statusLabel(),
                            style: TextStyle(
                              fontSize: NexoText.xs,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required this.segments,
    required this.progress,
    required this.statusColor,
    required this.glowAmount,
    required this.isDark,
  });

  final List<FamilyPulseSegment> segments;
  final double progress;
  final Color statusColor;
  final double glowAmount;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = 14.0;
    final ringRadius = radius - stroke / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: ringRadius);

    // Track de fundo
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = (isDark ? Colors.white : NexoColors.lightFg).withOpacity(0.06);
    canvas.drawCircle(center, ringRadius, trackPaint);

    // Glow externo (varia com o pulso)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 18
      ..color = statusColor.withOpacity(0.18 * glowAmount)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, ringRadius, glowPaint);

    // Soma dos pesos pra normalizar
    final totalWeight = segments.fold<double>(0, (s, e) => s + e.weight);
    if (totalWeight <= 0) {
      // Sem dados — desenha anel "vazio" indigo sutil
      final ghostPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = NexoColors.indigo.withOpacity(0.25);
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * 0.18 * progress, false, ghostPaint);
      return;
    }

    // Pequeno gap entre segmentos pra hierarquia
    final gapAngle = math.pi / 90; // ~2°
    final usableAngle = 2 * math.pi - gapAngle * segments.length;

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.weight / totalWeight) * usableAngle * progress;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [seg.color, seg.color.withOpacity(0.7)],
          startAngle: startAngle,
          endAngle: startAngle + sweep,
        ).createShader(rect);
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) =>
      old.progress != progress ||
      old.glowAmount != glowAmount ||
      old.statusColor != statusColor ||
      old.segments != segments ||
      old.isDark != isDark;
}
