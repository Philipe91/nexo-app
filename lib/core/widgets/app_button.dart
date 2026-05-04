import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { md, lg }

/// Botão padrão NEXO. Press-feedback (scale 0.97), loading inline,
/// acessibilidade nativa, altura mínima 52px.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
    this.iconRight,
    this.loading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? iconRight;
  final bool loading;
  final bool fullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: NexoMotion.micro,
    lowerBound: 0,
    upperBound: 0.03,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => widget.onPressed == null || widget.loading;

  ({Color bg, Color fg, BoxBorder? border, List<BoxShadow> shadow}) _styleFor(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;
        return (
          bg: accent,
          fg: Colors.white,
          border: null,
          shadow: NexoElevation.glow(accent, opacity: dark ? 0.30 : 0.22),
        );
      case AppButtonVariant.secondary:
        return (
          bg: dark ? NexoColors.darkSurfaceMuted : NexoColors.lightSurface,
          fg: dark ? NexoColors.darkFg : NexoColors.lightFg,
          border: Border.all(color: dark ? NexoColors.darkBorder : NexoColors.lightBorder),
          shadow: const [],
        );
      case AppButtonVariant.ghost:
        return (
          bg: Colors.transparent,
          fg: dark ? NexoColors.darkFg : NexoColors.lightFg,
          border: null,
          shadow: const [],
        );
      case AppButtonVariant.danger:
        final danger = dark ? NexoColors.dangerDark : NexoColors.danger;
        return (
          bg: danger,
          fg: Colors.white,
          border: null,
          shadow: NexoElevation.glow(danger, opacity: 0.20),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(context);
    final height = widget.size == AppButtonSize.lg ? 52.0 : 44.0;
    final fontSize = widget.size == AppButtonSize.lg ? NexoText.base : NexoText.md;

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: s.fg),
          )
        else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: s.fg),
          const SizedBox(width: 8),
        ],
        if (!widget.loading)
          Flexible(
            child: Text(
              widget.label,
              style: AppTheme.display(size: fontSize, weight: FontWeight.w600, color: s.fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (!widget.loading && widget.iconRight != null) ...[
          const SizedBox(width: 8),
          Icon(widget.iconRight, size: 18, color: s.fg),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: !_disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _disabled ? null : (_) => _ctrl.forward(),
        onTapUp: _disabled ? null : (_) => _ctrl.reverse(),
        onTapCancel: _disabled ? null : () => _ctrl.reverse(),
        onTap: _disabled ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(scale: 1 - _ctrl.value, child: child),
          child: AnimatedOpacity(
            duration: NexoMotion.micro,
            opacity: _disabled && !widget.loading ? 0.4 : 1,
            child: AnimatedContainer(
              duration: NexoMotion.normal,
              curve: NexoMotion.standard,
              height: height,
              width: widget.fullWidth ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: s.bg,
                border: s.border,
                borderRadius: BorderRadius.circular(NexoRadius.md),
                boxShadow: _disabled ? const [] : s.shadow,
              ),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
