import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';

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
      context.read<MemberProvider>().addMember(
            _memberController.text, 
            "0xFF4D5BCE", // Cor Azul Padrão
          );
      _memberController.clear();
    }
  }

  void _finish() {
    final members = context.read<MemberProvider>().members;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adicione pelo menos um membro.")),
      );
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Quem faz parte da\nFamília ${widget.familyName}?",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Input de Nome
                GlassCard(
                  opacity: 0.2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _memberController,
                            // CORRIGIDO: Cor preta para aparecer no fundo branco
                            style: const TextStyle(color: Colors.black), 
                            decoration: const InputDecoration(
                              hintText: "Nome do membro (Ex: Pai, Mãe...)",
                              // CORRIGIDO: Cinza para o texto de ajuda ficar legível
                              hintStyle: TextStyle(color: Colors.black54), 
                              border: InputBorder.none,
                            ),
                            textCapitalization: TextCapitalization.words,
                            onSubmitted: (_) => _addMember(),
                          ),
                        ),
                        IconButton(
                          onPressed: _addMember,
                          icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Lista de Membros Adicionados
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GlassCard(
                          opacity: 0.1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Text(member.name[0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () {
                                context.read<MemberProvider>().removeMember(member.id);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Tudo Pronto! Começar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}