import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Chip/tag NEXO. Selecionável, opcionalmente com ícone leading e remove.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.color,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? (dark ? NexoColors.indigoSoft : NexoColors.indigo);
    final bg = selected
        ? accent.withOpacity(0.12)
        : (dark ? NexoColors.darkSurfaceMuted : NexoColors.lightSurfaceMuted);
    final border = selected
        ? accent.withOpacity(0.40)
        : (dark ? NexoColors.darkBorder : NexoColors.lightBorder);
    final fg = selected ? accent : (dark ? NexoColors.darkFg : NexoColors.lightFg);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NexoRadius.pill),
        child: AnimatedContainer(
          duration: NexoMotion.normal,
          curve: NexoMotion.standard,
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(NexoRadius.pill),
            border: Border.all(color: border, width: selected ? 1.2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: NexoText.sm,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.close_rounded, size: 14, color: fg),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
