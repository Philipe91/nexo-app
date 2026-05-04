import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Helper pra abrir bottom sheets padrão NEXO.
///
/// Uso:
/// ```
/// AppBottomSheet.show(
///   context: context,
///   title: 'Opções',
///   child: ...,
/// );
/// ```
class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    bool isScrollControlled = true,
    bool useSafeArea = true,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      barrierColor: Colors.black.withOpacity(dark ? 0.65 : 0.45),
      builder: (ctx) => _SheetShell(title: title, subtitle: subtitle, child: child),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child, this.title, this.subtitle});
  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? NexoColors.darkSurface : NexoColors.lightSurface;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    final handle = dark ? NexoColors.darkBorderStrong : NexoColors.lightBorderStrong;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(NexoRadius.xl)),
        border: Border(
          top: BorderSide(color: dark ? NexoColors.darkBorder : NexoColors.lightBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(NexoSpace.xl, NexoSpace.lg, NexoSpace.xl, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: AppTheme.display(size: NexoText.xl, weight: FontWeight.w800, color: fg),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: NexoText.sm, color: fgMuted, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    NexoSpace.xl, NexoSpace.lg, NexoSpace.xl, NexoSpace.xl),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
