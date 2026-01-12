import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças do tema para atualizar o ícone do switch
    final themeController = ThemeController.instance;

    return Drawer(
      child: Column(
        children: [
          // Cabeçalho do Menu
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: const Text("Família App"),
            accountEmail: const Text("Versão Alpha 0.1"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.home, color: Colors.green),
            ),
          ),
          
          // Itens de Navegação
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              // Navegação futura aqui
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text("Responsabilidades"),
            onTap: () {},
          ),
          
          const Spacer(), // Empurra o conteúdo abaixo para o fim da tela
          const Divider(),
          
          // --- CONTROLE DO MODO DARK ---
          ListTile(
            leading: Icon(themeController.isDarkMode 
                ? Icons.dark_mode 
                : Icons.light_mode),
            title: const Text("Modo Escuro"),
            trailing: Switch(
              value: themeController.isDarkMode,
              activeColor: Colors.green,
              onChanged: (value) {
                themeController.toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}