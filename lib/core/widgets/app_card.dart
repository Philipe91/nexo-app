import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Card padrão NEXO. Hairline border + sombra sutil. Pode ser tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NexoSpace.lg),
    this.onTap,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.elevated = false,
    this.glow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final bool elevated;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(NexoRadius.lg);
    final bg = color ?? (dark ? NexoColors.darkSurface : NexoColors.lightSurface);
    final border = borderColor ?? (dark ? NexoColors.darkBorder : NexoColors.lightBorder);

    final shadows = <BoxShadow>[
      if (glow != null) ...NexoElevation.glow(glow!, opacity: dark ? 0.18 : 0.12),
      if (elevated) ...NexoElevation.raised else ...NexoElevation.card,
    ];

    Widget body = AnimatedContainer(
      duration: NexoMotion.normal,
      curve: NexoMotion.standard,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border),
        boxShadow: shadows,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return body;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: NexoColors.indigoGlow,
        highlightColor: NexoColors.indigoGlow,
        child: body,
      ),
    );
  }
}
