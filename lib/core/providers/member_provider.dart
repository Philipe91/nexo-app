import 'package:flutter/material.dart';

class MemberProvider extends ChangeNotifier {
  // Lista inicial com alguns padrões
  final List<String> _members = ['Mãe', 'Pai', 'Filho', 'Filha'];

  // Getter para proteger a lista original
  List<String> get members => _members;

  // Adicionar membro
  void addMember(String name) {
    if (!_members.contains(name)) {
      _members.add(name);
      notifyListeners(); // Avisa o app que mudou
    }
  }

  // Remover membro
  void removeMember(String name) {
    _members.remove(name);
    notifyListeners();
  }
}