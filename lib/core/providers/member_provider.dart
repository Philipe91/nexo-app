import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/member_model.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];

  List<Member> get members => _members;

  MemberProvider() {
    loadMembers();
  }

  // --- AÇÕES ---

  void addMember(String name) {
    final newMember = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: '0xFF4D5BCE', // Azul padrão
    );
    _members.add(newMember);
    saveMembers();
    notifyListeners();
  }

  void removeMember(String id) {
    _members.removeWhere((member) => member.id == id);
    saveMembers();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    // Transforma a lista de objetos em texto JSON
    final String data = jsonEncode(_members.map((m) => m.toMap()).toList());
    await prefs.setString('members_data', data);
  }

  Future<void> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('members_data')) {
      final String data = prefs.getString('members_data')!;
      final List<dynamic> decodedList = jsonDecode(data);
      
      _members = decodedList.map((item) => Member.fromMap(item)).toList();
      notifyListeners();
    }
  }
}