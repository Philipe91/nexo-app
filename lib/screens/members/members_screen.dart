import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/models/member_model.dart';
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Text(memberToEdit != null ? "Editar Membro" : "Novo Membro", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2D3142)),
              textAlign: TextAlign.center,
            ),
            content:  Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome ou Apelido",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.grey),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(height: 24),
                
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("Escolha uma cor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey))
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _colorOptions.map((color) {
                      String colorString = "0x${color.value.toRadixString(16).toUpperCase()}";
                      bool isSelected = _selectedColor == colorString;
                      
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            _selectedColor = colorString;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 48 : 40,
                          height: isSelected ? 48 : 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.transparent, width: 2),
                            boxShadow: [
                              if(isSelected) BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    if (memberToEdit != null) {
                      final updated = Member(
                        id: memberToEdit.id,
                        userId: memberToEdit.userId,
                        familyId: memberToEdit.familyId,
                        name: _nameController.text,
                        role: memberToEdit.role,
                        color: _selectedColor,
                        joinedAt: memberToEdit.joinedAt,
                        xp: memberToEdit.xp,
                        level: memberToEdit.level,
                        badges: memberToEdit.badges,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E5AE8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(memberToEdit != null ? "Salvar Alterações" : "Adicionar"),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Membros", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E5AE8).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showMemberDialog(),
          label: const Text("Novo Membro", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          icon: const Icon(Icons.person_add, color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          // Fundo base
          Container(color: const Color(0xFFF8F9FE)),

          // Header Curvo
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Stack(
              children: [
                 Positioned(top: -50, right: -50, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1))),
                 Positioned(bottom: 20, left: -20, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
              ],
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: members.isEmpty
                      ? const EmptyState(
                          icon: Icons.group_off_rounded,
                          title: "Nenhum membro ainda",
                          message: "Adicione as pessoas da sua família para começar a dividir as tarefas.",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassCard(
                                opacity: 1.0,
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: Container(
                                      width: 50, height: 50,
                                      decoration: BoxDecoration(
                                        color: avatarColor.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                                        style: TextStyle(fontWeight: FontWeight.w900, color: avatarColor, fontSize: 22),
                                      ),
                                    ),
                                    title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D3142))),
                                    subtitle: Text("Nível ${member.level} • ${member.xp} XP", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_rounded, color: Colors.grey),
                                          onPressed: () => _showMemberDialog(memberToEdit: member),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                          onPressed: () => _confirmDelete(member),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}