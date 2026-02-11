import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];

  List<Member> get members => _members;

  MemberProvider() {
    loadMembers();
  }

  // --- AÇÕES ---

  void addMember(String name, String color) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMember = Member(
      id: newId,
      userId: newId, // Local ID as userID for now
      familyId: 'local_family',
      name: name,
      role: 'child', // Defaulting to child for local adds? Or adult?
      color: color,
      joinedAt: DateTime.now(),
    );
    _members.add(newMember);
    saveMembers();
    notifyListeners();
  }

  // --- NOVO: GAMIFICATION ---
  
  bool addXp(String memberId, int amount) {
    bool leveledUp = false;
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index >= 0) {
      final member = _members[index];
      int newXp = member.xp + amount;
      int newLevel = _calculateLevel(newXp);

      // Verifica se subiu de nível
      if (newLevel > member.level) {
        leveledUp = true;
        print("🎉 LEVEL UP! ${member.name} subiu para o nível $newLevel!");
      }

      _members[index] = Member(
        id: member.id,
        userId: member.userId,
        familyId: member.familyId,
        name: member.name,
        role: member.role,
        color: member.color,
        joinedAt: member.joinedAt,
        xp: newXp,
        level: newLevel,
        badges: member.badges,
      );
      saveMembers();
      notifyListeners();
    }
    return leveledUp;
  }

  void unlockBadge(String memberId, String badgeId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index >= 0) {
      final member = _members[index];
      if (!member.badges.contains(badgeId)) {
        final newBadges = List<String>.from(member.badges)..add(badgeId);
        _members[index] = Member(
          id: member.id,
          userId: member.userId,
          familyId: member.familyId,
          name: member.name,
          role: member.role,
          color: member.color,
          joinedAt: member.joinedAt,
          xp: member.xp,
          level: member.level,
          badges: newBadges,
        );
        saveMembers();
        notifyListeners();
      }
    }
  }

  int _calculateLevel(int xp) {
    // Fórmula simples: Nível = 1 + (XP / 1000)
    // Ex: 0-999 = Lvl 1, 1000-1999 = Lvl 2
    return 1 + (xp ~/ 1000);
  }

  // --- ATUALIZAR MEMBRO GENÉRICO ---
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