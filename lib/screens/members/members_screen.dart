import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/member_model.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/empty_state.dart'; // <--- Import Novo

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _nameController = TextEditingController();
  String _selectedColor = "0xFF4D5BCE"; 

  final List<Color> _colorOptions = [
    const Color(0xFF4D5BCE), // Azul
    const Color(0xFFE91E63), // Rosa
    const Color(0xFF4CAF50), // Verde
    const Color(0xFFFF9800), // Laranja
    const Color(0xFF9C27B0), // Roxo
    const Color(0xFF795548), // Marrom
    const Color(0xFF607D8B), // Cinza Azulado
    const Color(0xFF000000), // Preto
  ];

  void _showMemberDialog({Member? memberToEdit}) {
    if (memberToEdit != null) {
      _nameController.text = memberToEdit.name;
      _selectedColor = memberToEdit.color;
    } else {
      _nameController.clear();
      _selectedColor = "0xFF4D5BCE";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text(memberToEdit != null ? "Editar Membro" : "Novo Membro"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nome / Apelido",
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                
                const Align(alignment: Alignment.centerLeft, child: Text("Cor do Avatar", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorOptions.map((color) {
                    String colorString = "0x${color.value.toRadixString(16).toUpperCase()}";
                    bool isSelected = _selectedColor == colorString;
                    
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedColor = colorString;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              FilledButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    if (memberToEdit != null) {
                      final updated = Member(
                        id: memberToEdit.id,
                        name: _nameController.text,
                        color: _selectedColor,
                      );
                      context.read<MemberProvider>().updateMember(updated);
                    } else {
                      context.read<MemberProvider>().addMember(
                        _nameController.text,
                        _selectedColor,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(memberToEdit != null ? "Salvar" : "Adicionar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir membro?"),
        content: Text("Tem certeza que deseja remover ${member.name}? As tarefas dele ficarão órfãs."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              context.read<MemberProvider>().removeMember(member.id);
              Navigator.pop(context); 
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;

    return Scaffold(
      extendBodyBehindAppBar: true, // Efeito bonito no topo
      appBar: AppBar(
        title: const Text("Gerenciar Membros", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMemberDialog(),
        label: const Text("Novo Membro"),
        icon: const Icon(Icons.person_add),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Stack(
        children: [
          // Fundo base
          Container(color: theme.colorScheme.background),
          
          SafeArea(
            child: members.isEmpty
                ? const EmptyState(
                    icon: Icons.group_off_rounded,
                    title: "Nenhum membro ainda",
                    message: "Adicione as pessoas da sua família para começar a dividir as tarefas.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      Color avatarColor;
                      try {
                        avatarColor = Color(int.parse(member.color));
                      } catch (e) {
                        avatarColor = Colors.grey;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        // GlassCard limpo (sem cor fixa) para adaptar ao tema
                        child: GlassCard(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: avatarColor.withOpacity(0.2),
                              child: Text(
                                member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                                style: TextStyle(fontWeight: FontWeight.bold, color: avatarColor, fontSize: 20),
                              ),
                            ),
                            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text("Membro da Família", style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _showMemberDialog(memberToEdit: member),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _confirmDelete(member),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}