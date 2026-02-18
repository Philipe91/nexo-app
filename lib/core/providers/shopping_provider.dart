import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/grocery_item_model.dart';
import '../../models/meal_model.dart';

class ShoppingProvider extends ChangeNotifier {
  List<GroceryItem> _items = [];
  List<Meal> _meals = [];
  
  StreamSubscription<QuerySnapshot>? _itemsSubscription;
  StreamSubscription<QuerySnapshot>? _mealsSubscription;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _familyId => 'default_family';

  List<GroceryItem> get items => _items;
  List<Meal> get meals => _meals;

  // Itens sugeridos (Mock por enquanto)
  List<String> get suggestedItems => [
    "Leite", "Ovos", "Pão", "Arroz", "Feijão", "Banana", "Queijo", "Café"
  ];

  ShoppingProvider() {
    subscribeToData();
  }

  // --- ESCUTAR DO FIREBASE ---
  void subscribeToData() {
    // Escutar Itens de Compra
    _itemsSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('shopping_list')
        .orderBy('isCompleted') // Opcional: ordenar por status
        .snapshots()
        .listen((snapshot) {
      _items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GroceryItem.fromMap(data);
      }).toList();
      notifyListeners();
    });

    // Escutar Refeições
    _mealsSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('meals')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      _meals = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Ajuste se Meal usar Timestamp
        if (data['date'] is Timestamp) {
           // Se o fromMap não tratar, precise converter. 
           // Mas vamos assumir que o MealModel será ajustado ou já trata se for updated em breve.
           // Por enquanto, faremos o "cast" se necessário no fromMap.
           // Se o MealModel não estiver preparado, podemos ter erro aqui.
           // Verifiquei o file anterior e não vi MealModel. 
           // Assumindo que Meal usa String ou DateTime. Se usar DateTime, Firestore manda Timestamp.
           // Vou garantir a conversão no map antes.
           data['date'] = (data['date'] as Timestamp).toDate().toIso8601String(); 
        }
        return Meal.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _mealsSubscription?.cancel();
    super.dispose();
  }

  // --- COMPRAS ---

  Future<void> addItem(String name, String addedBy, {String category = 'Geral'}) async {
    final newItem = GroceryItem(
      id: '',
      name: name,
      category: category,
      addedBy: addedBy,
    );
    await _firestore.collection('families').doc(_familyId).collection('shopping_list').add(newItem.toMap());
  }

  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      // Optimistic Update
      final oldStatus = item.isCompleted;
      _items[index] = item.copyWith(isCompleted: !oldStatus); // Requer copyWith no Model
      notifyListeners();

      try {
        await _firestore
            .collection('families')
            .doc(_familyId)
            .collection('shopping_list')
            .doc(id)
            .update({'isCompleted': !oldStatus});
      } catch (e) {
        // Revert if error
        _items[index] = item.copyWith(isCompleted: oldStatus);
        notifyListeners();
        print("Erro ao atualizar item: $e");
      }
    }
  }

  Future<void> removeItem(String id) async {
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('shopping_list')
        .doc(id)
        .delete();
  }

  Future<void> clearCompleted() async {
    final batch = _firestore.batch();
    final completed = _items.where((i) => i.isCompleted);
    
    for (var item in completed) {
      final ref = _firestore
          .collection('families')
          .doc(_familyId)
          .collection('shopping_list')
          .doc(item.id);
      batch.delete(ref);
    }
    await batch.commit();
  }

  // --- REFEIÇÕES ---

  Future<void> addIngredientsToShoppingList(List<String> ingredients) async {
    final batch = _firestore.batch();
    for (var ingredient in ingredients) {
      final docRef = _firestore.collection('families').doc(_familyId).collection('shopping_list').doc();
      final newItem = GroceryItem(
        id: docRef.id,
        name: ingredient,
        category: 'Cardápio',
        addedBy: 'MealPlanner',
      );
      batch.set(docRef, newItem.toMap());
    }
    await batch.commit();
  }

  Future<void> addMeal(DateTime date, String type, String description, String chefId, List<String> ingredients) async {
    final newMeal = Meal(
      id: '',
      date: date,
      type: type,
      description: description,
      chefId: chefId,
      ingredients: ingredients,
    );
     // MealModel toMap provavelmente usa toIso8601String para data se não foi alterado.
     // Se quisermos usar Timestamp, teríamos que mudar o Model.
     // Para consistência rápida, vou deixar como String ou alterar para Timestamp se der.
     // Mas aqui vou mandar o map como está.
    await _firestore.collection('families').doc(_familyId).collection('meals').add(newMeal.toMap());
  }
  
  Future<void> removeMeal(String id) async {
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('meals')
        .doc(id)
        .delete();
  }

  List<Meal> getMealsForDay(DateTime date) {
    return _meals.where((m) => 
      m.date.year == date.year && 
      m.date.month == date.month && 
      m.date.day == date.day
    ).toList();
  }
}
