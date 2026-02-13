import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: NavigationBar(
            height: 70, 
            elevation: 0,
            backgroundColor: Colors.transparent, // Transparente para mostrar o gradiente do Container
            indicatorColor: Colors.white.withOpacity(0.2), // Indicador sutil
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) => _onTap(context, index),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.list_alt_rounded, color: Colors.white),
                label: 'Tarefas',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.shopping_cart_rounded, color: Colors.white),
                label: 'Compras',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline, color: Colors.white70),
                selectedIcon: Icon(Icons.people_rounded, color: Colors.white),
                label: 'Membros',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so maintains the state of the previous branch, and
    // allows for extending the state of the current branch.
    navigationShell.goBranch(
      index,
      // A common pattern when switching branches is to support restoring the
      // initial location when tapping the item that is already active. This
      // example demonstrates how to support this behavior, using the
      // initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
