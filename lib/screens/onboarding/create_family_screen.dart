import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- Adicionamos esse import para poder navegar

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Família')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dê um nome para sua casa',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pode ser o sobrenome da família ou um apelido carinhoso.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Família',
                hintText: 'Ex: Família Silva, Toca do Urso...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            
            // --- AQUI ESTÁ A MUDANÇA DO PASSO 3 ---
            FilledButton(
              onPressed: () {
                // Só navega se o campo não estiver vazio
                if (_nameController.text.isNotEmpty) {
                  // Manda o texto digitado para a próxima tela
                  context.push('/add-members', extra: _nameController.text);
                }
              },
              child: const Text('Continuar'),
            ),
            // --------------------------------------
          ],
        ),
      ),
    );
  }
}