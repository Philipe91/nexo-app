import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      // Por enquanto, "addedBy" é fixo "Eu" (melhorar com Auth depois)
      context.read<ShoppingProvider>().addItem(_itemController.text, "Eu");
      _itemController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ShoppingProvider>();
    final items = provider.items.where((i) => !i.isCompleted).toList();
    final completedItems = provider.items.where((i) => i.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fundo suave
      appBar: AppBar(
        title: Text("Lista de Compras", style: GoogleFonts.fredoka(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey),
            onPressed: () => provider.clearCompleted(),
            tooltip: "Limpar concluídos",
          )
        ],
      ),
      body: Column(
        children: [
          // --- Input Rápido ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      hintText: "Adicionar item (ex: Leite)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: _addItem,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // --- Sugestões Rápidas ---
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: provider.suggestedItems.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(suggestion),
                    backgroundColor: Colors.white,
                    onPressed: () => provider.addItem(suggestion, "Eu"),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (items.isEmpty && completedItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text("Lista vazia!", style: GoogleFonts.inter(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                // --- Itens Pendentes ---
                ...items.map((item) => _buildGroceryItem(item, provider)),

                if (completedItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  Text("Concluídos", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // --- Itens Concluídos ---
                  ...completedItems.map((item) => _buildGroceryItem(item, provider)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryItem(GroceryItem item, ShoppingProvider provider) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.removeItem(item.id);
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: item.isCompleted ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
        color: item.isCompleted ? Colors.grey[100] : Colors.white,
        child: ListTile(
          leading: Checkbox(
            value: item.isCompleted,
            activeColor: Colors.green,
            shape: const CircleBorder(),
            onChanged: (_) => provider.toggleItem(item.id),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              color: item.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          trailing: item.category != 'Geral' 
              ? Chip(label: Text(item.category, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact) 
              : null,
        ),
      ),
    );
  }
}
