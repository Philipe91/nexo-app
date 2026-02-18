import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/shopping_provider.dart';
import '../../models/grocery_item_model.dart';
import '../../core/widgets/glass_card.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      context.read<ShoppingProvider>().addItem(_itemController.text, "Eu");
      _itemController.clear();
      // Manter foco para adicionar vários itens rapido
      _inputFocus.requestFocus(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ShoppingProvider>();
    final items = provider.items.where((i) => !i.isCompleted).toList();
    final completedItems = provider.items.where((i) => i.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Background Color style
      appBar: AppBar(
        title: Text("Compras", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (completedItems.isNotEmpty)
            TextButton(
              onPressed: () => provider.clearCompleted(),
              child: const Text("Limpar Feitos", style: TextStyle(color: Colors.red)),
            )
        ],
      ),
      body: Column(
        children: [
          // --- Lista de Itens ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (items.isEmpty && completedItems.isEmpty)
                   Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Icon(Icons.checklist_rtl_rounded, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text("Sua lista está vazia", style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),

                // Seção: Pendentes
                if (items.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text("A COMPRAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        return Column(
                          children: [
                            if (index > 0) const Divider(height: 1, indent: 48),
                            _buildItemRow(item, provider, theme),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Seção: Sugestões (Chips)
                if (items.length < 5) ...[ // Só mostra sugestões se a lista não estiver gigante
                   SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: provider.suggestedItems
                          // Filtra sugestões que já estão na lista (pendente ou completa)
                          .where((sug) => !provider.items.any((i) => i.name.toLowerCase() == sug.toLowerCase()))
                          .map((suggestion) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.add, size: 14),
                            label: Text(suggestion),
                            backgroundColor: Colors.white,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onPressed: () => provider.addItem(suggestion, "Eu"),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Seção: Concluídos
                if (completedItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text("CONCLUÍDO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: List.generate(completedItems.length, (index) {
                        final item = completedItems[index];
                        return Column(
                          children: [
                            if (index > 0) const Divider(height: 1, indent: 48),
                            _buildItemRow(item, provider, theme),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 100), // Espaço para input fixo
                ]
              ],
            ),
          ),
          
          // --- Input Fixo no Rodapé ---
          Container(
            padding: EdgeInsets.only(
              left: 16, 
              right: 16, 
              top: 12, 
              bottom: MediaQuery.of(context).viewInsets.bottom + 12
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ]
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: _addItem,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    focusNode: _inputFocus,
                    decoration: const InputDecoration(
                      hintText: "Novo item...",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                    style: const TextStyle(fontSize: 18),
                    onSubmitted: (_) => _addItem(),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(GroceryItem item, ShoppingProvider provider, ThemeData theme) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.removeItem(item.id),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () => provider.toggleItem(item.id),
          child: AnimatedContainer(
            duration: 200.ms,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isCompleted ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: item.isCompleted ? theme.colorScheme.primary : Colors.grey.shade400,
                width: 2
              ),
            ),
            child: item.isCompleted 
              ? const Icon(Icons.check, size: 16, color: Colors.white) 
              : null,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 17,
            color: item.isCompleted ? Colors.grey : Colors.black87,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: item.category != 'Geral' 
            ? Text(
                item.category, 
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)
              ) 
            : null,
      ),
    );
  }
}
