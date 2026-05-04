import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tokens.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;
    final navBg = (dark ? NexoColors.darkSurface : NexoColors.lightSurface).withOpacity(0.85);
    final border = dark ? NexoColors.darkBorder : NexoColors.lightBorder;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: _AssistantFab(accent: accent, onTap: () => context.push('/assistant')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(NexoRadius.xl)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: navBg,
              border: Border(top: BorderSide(color: border)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _NavTile(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Início',
                      selected: navigationShell.currentIndex == 0,
                      onTap: () => _go(0),
                      fg: fg,
                      fgMuted: fgMuted,
                      accent: accent,
                    ),
                    _NavTile(
                      icon: Icons.checklist_outlined,
                      activeIcon: Icons.checklist_rounded,
                      label: 'Tarefas',
                      selected: navigationShell.currentIndex == 1,
                      onTap: () => _go(1),
                      fg: fg,
                      fgMuted: fgMuted,
                      accent: accent,
                    ),
                    const SizedBox(width: 64), // espaço do FAB
                    _NavTile(
                      icon: Icons.shopping_basket_outlined,
                      activeIcon: Icons.shopping_basket_rounded,
                      label: 'Compras',
                      selected: navigationShell.currentIndex == 2,
                      onTap: () => _go(2),
                      fg: fg,
                      fgMuted: fgMuted,
                      accent: accent,
                    ),
                    _NavTile(
                      icon: Icons.people_outline,
                      activeIcon: Icons.people_rounded,
                      label: 'Membros',
                      selected: navigationShell.currentIndex == 3,
                      onTap: () => _go(3),
                      fg: fg,
                      fgMuted: fgMuted,
                      accent: accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fg,
    required this.fgMuted,
    required this.accent,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color fg;
  final Color fgMuted;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1.0,
              duration: NexoMotion.normal,
              curve: NexoMotion.standard,
              child: Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? accent : fgMuted,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: NexoMotion.normal,
              style: TextStyle(
                fontSize: NexoText.xs,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : fgMuted,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantFab extends StatelessWidget {
  const _AssistantFab({required this.accent, required this.onTap});
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: NexoElevation.glow(accent, opacity: 0.40),
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: accent,
        elevation: 0,
        shape: const CircleBorder(),
        tooltip: 'Assistente NEXO',
        child: const Icon(Icons.auto_awesome_outlined, size: 26, color: Colors.white),
      ),
    );
  }
}
