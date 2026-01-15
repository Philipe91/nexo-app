import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';

class AddMembersScreen extends StatefulWidget {
  final String familyName;

  const AddMembersScreen({super.key, required this.familyName});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final _nameController = TextEditingController();
  
  // Cores pré-definidas para facilitar
  final List<Color> _avatarColors = [
    const Color(0xFF4D5BCE), // Azul
    const Color(0xFFE91E63), // Rosa
    const Color(0xFF4CAF50), // Verde
    const Color(0xFFFF9800), // Laranja
    const Color(0xFF9C27B0), // Roxo
  ];

  void _addMember() {
    if (_nameController.text.isNotEmpty) {
      // Escolhe uma cor aleatória da lista
      final randomColor = (_avatarColors..shuffle()).first;
      final colorString = "0x${randomColor.value.toRadixString(16).padLeft(8, '0')}";

      context.read<MemberProvider>().addMember(
            _nameController.text, 
            colorString, 
          );
      _nameController.clear();
      
      // Feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_nameController.text} adicionado!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _finish() {
    final members = context.read<MemberProvider>().members;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione pelo menos um membro (ex: você!)"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // CORREÇÃO: Mudamos de '/home' para '/'
    context.go('/'); 
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;

    return Scaffold(
      appBar: AppBar(
        title: Text("Membros da ${widget.familyName}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Área de Input
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Quem mora na casa?",
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Nome (ex: Mamãe, João...)",
                          prefixIcon: const Icon(Icons.person_add_alt_1),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: theme.colorScheme.background,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addMember(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: _addMember,
                      mini: true,
                      elevation: 0,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Membros Adicionados
          Expanded(
            child: members.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.groups_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "A casa está vazia...",
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      // Converte string hex para Color
                      final color = Color(int.parse(member.color));
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          opacity: 0.8,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Text(
                                member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              member.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                context.read<MemberProvider>().removeMember(member.id);
                              },
                            ),
                          ),
                        ),
                      ).animate().fade().slideX();
                    },
                  ),
          ),

          // Botão Continuar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _finish,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("CONCLUIR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}