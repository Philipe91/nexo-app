import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddMembersScreen extends StatefulWidget {
  final String familyName; // Recebe o nome da família

  const AddMembersScreen({super.key, required this.familyName});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final List<String> _members = []; // Lista de pessoas
  final _memberController = TextEditingController();

  void _addMember() {
    if (_memberController.text.isNotEmpty) {
      setState(() {
        _members.add(_memberController.text);
        _memberController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  widget.familyName, // Mostra o nome da família
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

          // Campo de texto e botão +
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

          // Lista de membros adicionados
          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text(_members[index][0])),
                  title: Text(_members[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _members.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Botão Finalizar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _members.isNotEmpty 
                  ? () {
                      // Finaliza o onboarding e vai pra Home
                      context.go('/home'); 
                    } 
                  : null, // Desabilita se lista vazia
                child: const Text('Finalizar Cadastro'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}