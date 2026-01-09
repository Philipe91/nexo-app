import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/member_provider.dart';

class AddMembersScreen extends StatefulWidget {
  final String familyName;

  const AddMembersScreen({super.key, required this.familyName});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final _memberController = TextEditingController();

  void _addMember() {
    if (_memberController.text.isNotEmpty) {
      // Salva diretamente no Provider (Persistência)
      context.read<MemberProvider>().addMember(_memberController.text);
      _memberController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Escuta o provider para atualizar a lista na tela
    final members = context.watch<MemberProvider>().members;

    return Scaffold(
      appBar: AppBar(title: const Text('Quem mora aqui?')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.familyName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione as pessoas da casa.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberController,
                    decoration: const InputDecoration(
                      hintText: 'Nome da pessoa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _addMember,
                  icon: const Icon(Icons.add),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(member.name[0].toUpperCase())),
                  title: Text(member.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<MemberProvider>().removeMember(member.id);
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: members.isNotEmpty 
                  ? () => context.go('/home') 
                  : null,
                child: const Text('Finalizar Cadastro'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}