import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class AppSegment {
  const AppSegment({required this.value, required this.label, this.icon});
  final String value;
  final String label;
  final IconData? icon;
}

/// Segmented control estilo iOS Settings — para alternar abas pequenas.
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<AppSegment> segments;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? NexoColors.darkSurfaceMuted : NexoColors.lightSurfaceMuted;
    final border = dark ? NexoColors.darkBorder : NexoColors.lightBorder;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: muted,
        borderRadius: BorderRadius.circular(NexoRadius.md),
        border: Border.all(color: border),
      ),
      child: Row(
        children: segments.map((s) {
          return Expanded(child: _Tile(segment: s, selected: s.value == value, onTap: () => onChanged(s.value)));
        }).toList(),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.segment, required this.selected, required this.onTap});
  final AppSegment segment;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = dark ? NexoColors.darkSurface : NexoColors.lightSurface;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NexoMotion.normal,
        curve: NexoMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(NexoRadius.sm),
          boxShadow: selected ? NexoElevation.card : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (segment.icon != null) ...[
              Icon(segment.icon, size: 14, color: selected ? fg : fgMuted),
              const SizedBox(width: 6),
            ],
            Text(
              segment.label,
              style: TextStyle(
                fontSize: NexoText.sm,
                fontWeight: FontWeight.w600,
                color: selected ? fg : fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
