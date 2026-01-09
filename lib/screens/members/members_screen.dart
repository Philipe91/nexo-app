import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // <--- Importante
import '../../core/providers/member_provider.dart'; // <--- Importante

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _nameController = TextEditingController();

  void _addMember() {
    if (_nameController.text.isNotEmpty) {
      // ADICIONA NO PROVIDER GLOBAL
      context.read<MemberProvider>().addMember(_nameController.text);
      _nameController.clear();
      Navigator.pop(context);
    }
  }

  void _removeMember(String name) {
    // REMOVE DO PROVIDER GLOBAL
    context.read<MemberProvider>().removeMember(name);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo Membro"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Nome ou Apelido",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          FilledButton(onPressed: _addMember, child: const Text("Adicionar")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ESCUTA A LISTA GLOBAL DE MEMBROS
    final memberProvider = context.watch<MemberProvider>();
    final members = memberProvider.members;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("Membros da Família", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: members.isEmpty 
        ? const Center(child: Text("Nenhum membro adicionado"))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getAvatarColor(index),
                    child: Text(member[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(member, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: const Text("Membro da Família"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _removeMember(member),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.person_add),
        label: const Text("Adicionar"),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink];
    return colors[index % colors.length];
  }
}