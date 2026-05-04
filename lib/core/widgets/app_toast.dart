import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AppToastKind { info, success, warning, danger }

/// Toast pílula flutuante NEXO. Usado em vez de SnackBar.
///
/// `AppToast.show(context, 'Tarefa criada', kind: AppToastKind.success);`
class AppToast {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    AppToastKind kind = AppToastKind.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    _dismiss();
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, kind: kind, icon: icon),
    );
    overlay.insert(entry);
    _current = entry;
    _timer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _current?.remove();
    _current = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({required this.message, required this.kind, this.icon});
  final String message;
  final AppToastKind kind;
  final IconData? icon;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: NexoMotion.normal)..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  ({Color bg, Color fg, IconData icon}) _palette(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.kind) {
      case AppToastKind.success:
        return (bg: NexoColors.success, fg: Colors.white, icon: Icons.check_circle_outline_rounded);
      case AppToastKind.warning:
        return (
          bg: dark ? NexoColors.warningDark : NexoColors.warning,
          fg: Colors.white,
          icon: Icons.warning_amber_rounded,
        );
      case AppToastKind.danger:
        return (
          bg: dark ? NexoColors.dangerDark : NexoColors.danger,
          fg: Colors.white,
          icon: Icons.error_outline_rounded,
        );
      case AppToastKind.info:
        return (
          bg: dark ? NexoColors.darkSurfaceElevated : NexoColors.lightFg,
          fg: dark ? NexoColors.darkFg : Colors.white,
          icon: Icons.info_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context);
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) {
            final t = Curves.easeOutCubic.transform(_ctrl.value);
            return Transform.translate(
              offset: Offset(0, (1 - t) * -40),
              child: Opacity(opacity: t, child: child),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(NexoRadius.pill),
                    boxShadow: NexoElevation.raised,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon ?? p.icon, color: p.fg, size: 18),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: p.fg,
                            fontSize: NexoText.sm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
