import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/agreement_model.dart';

class AgreementProvider extends ChangeNotifier {
  List<Agreement> _agreements = [];

  List<Agreement> get agreements => _agreements;

  AgreementProvider() {
    loadAgreements();
  }

  // --- AÇÕES ---

  void addAgreement(String title, String description) {
    final newAgreement = Agreement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    _agreements.add(newAgreement);
    saveAgreements();
    notifyListeners();
  }

  void removeAgreement(String id) {
    _agreements.removeWhere((a) => a.id == id);
    saveAgreements();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveAgreements() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_agreements.map((a) => a.toMap()).toList());
    await prefs.setString('agreements_data', data);
  }

  Future<void> loadAgreements() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('agreements_data')) {
      final String data = prefs.getString('agreements_data')!;
      final List<dynamic> decodedList = jsonDecode(data);
      _agreements = decodedList.map((item) => Agreement.fromMap(item)).toList();
      notifyListeners();
    }
  }
}