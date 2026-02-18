import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers/shopping_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/meal_model.dart';
import '../../core/models/member_model.dart';
import '../../core/widgets/glass_card.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  // Garante que a data selecionada não tenha hora/minuto
  DateTime get _cleanDate {
    return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
  }

  void _changeDate(int  daysToAdd) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysToAdd));
    });
  }

  void _addMealDialog(BuildContext context, String type) {
    final TextEditingController descController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController(); // Novo controller
    final memberProvider = context.read<MemberProvider>();
    String? selectedChefId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Planejar $type", style: GoogleFonts.fredoka()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Prato (ex: Lasanha)", 
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(
                    labelText: "Ingredientes (separe por vírgula)", 
                    hintText: "Massa, Queijo, Molho...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedChefId,
                  decoration: const InputDecoration(labelText: "Quem cozinha? (Chef)"),
                  items: memberProvider.members.map((m) {
                    return DropdownMenuItem(value: m.id, child: Text(m.name));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedChefId = val),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
              ElevatedButton(
                onPressed: () {
                  if (descController.text.isNotEmpty && selectedChefId != null) {
                    // Processar ingredientes
                    List<String> ingredients = [];
                    if (ingredientsController.text.isNotEmpty) {
                      ingredients = ingredientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    }

                    context.read<ShoppingProvider>().addMeal(
                      _cleanDate, 
                      type, 
                      descController.text, 
                      selectedChefId!,
                      ingredients // Passar lista
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = context.watch<ShoppingProvider>();
    final memberProvider = context.watch<MemberProvider>();
    
    // Filtra refeições do dia selecionado
    final meals = shoppingProvider.getMealsForDay(_cleanDate);

    final lunch = meals.firstWhere((m) => m.type == 'Almoço', orElse: () => Meal(id: '', date: DateTime.now(), type: '', description: '', chefId: ''));
    final dinner = meals.firstWhere((m) => m.type == 'Jantar', orElse: () => Meal(id: '', date: DateTime.now(), type: '', description: '', chefId: ''));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Cardápio", style: GoogleFonts.fredoka(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- Calendário Semanal Simplificado ---
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14, // 2 semanas
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(const Duration(days: 2)).add(Duration(days: index));
                final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4E5AE8) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (isSelected) 
                          BoxShadow(color: const Color(0xFF4E5AE8).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat.E('pt_BR').format(date).toUpperCase(), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey)),
                        Text(date.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildMealCard(
                  title: "Almoço",
                  icon: Icons.sunny,
                  color: const Color(0xFFFFD740), // Amarelo Accent (Moon Heart) em vez de Orange
                  meal: lunch.id.isNotEmpty ? lunch : null,
                  onAdd: () => _addMealDialog(context, "Almoço"),
                  members: memberProvider.members,
                  onRemove: (id) => shoppingProvider.removeMeal(id),
                ),
                const SizedBox(height: 20),
                _buildMealCard(
                  title: "Jantar",
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF4E5AE8), // Indigo Primary
                  meal: dinner.id.isNotEmpty ? dinner : null,
                  onAdd: () => _addMealDialog(context, "Jantar"),
                  members: memberProvider.members,
                  onRemove: (id) => shoppingProvider.removeMeal(id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required String title, 
    required IconData icon, 
    required Color color, 
    Meal? meal, 
    required VoidCallback onAdd,
    required List<Member> members,
    required Function(String) onRemove,
  }) {
    Member? chef;
    if (meal != null) {
      try {
        chef = members.firstWhere((m) => m.id == meal.chefId);
      } catch (_) {}
    }

    return GlassCard(
      color: Colors.white,
      opacity: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.fredoka(fontSize: 20, color: color)),
                const Spacer(),
                if (meal != null)
                   IconButton(onPressed: () => onRemove(meal.id), icon: const Icon(Icons.delete_outline, color: Colors.red)),
              ],
            ),
            const Divider(),
            if (meal == null)
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.add_circle_outline, size: 32, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text("Adicionar prato e Chef", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    meal.description, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (meal.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: meal.ingredients.map((i) => Chip(
                        label: Text(i, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      )).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Chef: ", style: TextStyle(color: Colors.grey[600])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: chef != null ? Color(int.parse(chef.color)).withOpacity(0.2) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant_menu, size: 16, color: chef != null ? Color(int.parse(chef.color)) : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              chef?.name ?? "Desconhecido", 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: chef != null ? Color(int.parse(chef.color)) : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  if (meal.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<ShoppingProvider>().addIngredientsToShoppingList(meal.ingredients);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${meal.ingredients.length} itens adicionados à lista!"),
                              backgroundColor: Colors.green,
                            )
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text("Adicionar à Lista"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ],
              )
          ],
        ),
      ),
    );
  }
}
