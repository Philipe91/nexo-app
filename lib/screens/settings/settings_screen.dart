import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/preferences_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  // Função para Editar Nome da Família
  void _editFamilyName(BuildContext context) {
    final prefs = context.read<PreferencesProvider>();
    final controller = TextEditingController(text: prefs.familyName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nome da Casa"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Ex: Toca do Urso",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                prefs.updateFamilyName(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apagar tudo?"),
        content: const Text("Isso excluirá todos os dados. Essa ação é irreversível."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apagar Tudo"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        context.go('/'); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = context.watch<PreferencesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("GERAL", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("Nome da Casa"),
            subtitle: Text(prefs.familyName),
            trailing: const Icon(Icons.edit, size: 16),
            onTap: () => _editFamilyName(context),
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Modo Escuro"),
            value: prefs.isDarkMode,
            onChanged: (val) => prefs.toggleTheme(val),
          ),

          const Divider(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("DADOS", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Resetar Aplicativo", style: TextStyle(color: Colors.red)),
            onTap: () => _resetApp(context),
          ),
          
          const SizedBox(height: 32),
          Center(child: Text("NEXO v1.1.0", style: TextStyle(color: Colors.grey.shade400, fontSize: 12))),
        ],
      ),
    );
  }
}