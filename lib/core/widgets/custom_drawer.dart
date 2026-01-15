import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/preferences_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o Provider de Preferências para pegar o nome e o tema
    final prefs = context.watch<PreferencesProvider>();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(prefs.familyName), // Nome dinâmico da família
            accountEmail: const Text("Versão Beta 1.0"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.home_rounded, color: Theme.of(context).primaryColor),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text("Dashboard"),
            onTap: () {
              context.go('/');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text("Responsabilidades"),
            onTap: () {
              context.push('/responsibilities');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.handshake_outlined),
            title: const Text("Acordos"),
            onTap: () {
              context.push('/agreements');
              Navigator.pop(context);
            },
          ),
           ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text("Membros"),
            onTap: () {
              context.push('/members');
              Navigator.pop(context);
            },
          ),
          
          const Spacer(), 
          const Divider(),
          
          // Switch do Modo Escuro
          ListTile(
            leading: Icon(prefs.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            title: const Text("Modo Escuro"),
            trailing: Switch(
              value: prefs.isDarkMode,
              activeColor: Colors.green,
              onChanged: (bool value) {
                context.read<PreferencesProvider>().toggleTheme(value);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}