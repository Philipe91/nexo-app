import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/agreement_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetApp(BuildContext context) async {
    // 1. Confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apagar tudo?"),
        content: const Text("Isso excluirá todos os membros, tarefas e acordos. O app voltará para o início."),
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
      // 2. Limpa o Banco de Dados Local
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Força o reinício (Navega para a rota inicial e limpa a pilha)
      if (context.mounted) {
        // O ideal seria limpar os Providers também, mas o Hot Restart do app fará isso.
        // Aqui forçamos a ida para o Onboarding.
        context.go('/'); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("App resetado com sucesso!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Sobre o NEXO"),
            subtitle: const Text("Versão 1.0.0 (Alpha)"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Resetar Aplicativo", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text("Apaga todos os dados e volta ao início"),
            onTap: () => _resetApp(context),
          ),
        ],
      ),
    );
  }
}