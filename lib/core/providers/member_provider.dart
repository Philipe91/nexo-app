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

  void addMember(String name, String color) {
    final newMember = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    );
    _members.add(newMember);
    saveMembers();
    notifyListeners();
  }

  // --- NOVO: ATUALIZAR MEMBRO ---
  void updateMember(Member updatedMember) {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index >= 0) {
      _members[index] = updatedMember;
      saveMembers();
      notifyListeners();
    }
  }

  void removeMember(String id) {
    _members.removeWhere((member) => member.id == id);
    saveMembers();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_members.map((m) => m.toMap()).toList());
    await prefs.setString('members_data', data);
  }

  Future<void> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('members_data')) {
      final String data = prefs.getString('members_data')!;
      // Decodifica a lista com segurança
      final List<dynamic> decodedList = jsonDecode(data);
      _members = decodedList.map((item) => Member.fromMap(item)).toList();
      notifyListeners();
    }
  }
}