import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/grocery_item_model.dart';
import '../../models/meal_model.dart';

class ShoppingProvider extends ChangeNotifier {
  List<GroceryItem> _items = [];
  List<Meal> _meals = [];

  List<GroceryItem> get items => _items;
  List<Meal> get meals => _meals;

  // Itens sugeridos (Mock por enquanto)
  List<String> get suggestedItems => [
    "Leite", "Ovos", "Pão", "Arroz", "Feijão", "Banana", "Queijo", "Café"
  ];

  ShoppingProvider() {
    loadData();
  }

  // --- COMPRAS ---

  void addItem(String name, String addedBy, {String category = 'Geral'}) {
    final newItem = GroceryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      addedBy: addedBy,
    );
    _items.add(newItem);
    saveData();
    notifyListeners();
  }

  void toggleItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = GroceryItem(
        id: item.id,
        name: item.name,
        category: item.category,
        isCompleted: !item.isCompleted,
        quantity: item.quantity,
        addedBy: item.addedBy,
      );
      saveData();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    saveData();
    notifyListeners();
  }

  void clearCompleted() {
    _items.removeWhere((item) => item.isCompleted);
    saveData();
    notifyListeners();
  }

  // --- REFEIÇÕES ---

  void addMeal(DateTime date, String type, String description, String chefId) {
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      type: type,
      description: description,
      chefId: chefId,
    );
    _meals.add(newMeal);
    saveData();
    notifyListeners();
  }
  
  void removeMeal(String id) {
    _meals.removeWhere((m) => m.id == id);
    saveData();
    notifyListeners();
  }

  List<Meal> getMealsForDay(DateTime date) {
    return _meals.where((m) => 
      m.date.year == date.year && 
      m.date.month == date.month && 
      m.date.day == date.day
    ).toList();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsData = jsonEncode(_items.map((i) => i.toMap()).toList());
    final String mealsData = jsonEncode(_meals.map((m) => m.toMap()).toList());
    
    await prefs.setString('shopping_items', itemsData);
    await prefs.setString('meals_data', mealsData);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('shopping_items')) {
      final String data = prefs.getString('shopping_items')!;
      final List<dynamic> decoded = jsonDecode(data);
      _items = decoded.map((i) => GroceryItem.fromMap(i)).toList();
    }

    if (prefs.containsKey('meals_data')) {
      final String data = prefs.getString('meals_data')!;
      final List<dynamic> decoded = jsonDecode(data);
      _meals = decoded.map((m) => Meal.fromMap(m)).toList();
    }
    
    notifyListeners();
  }
}
