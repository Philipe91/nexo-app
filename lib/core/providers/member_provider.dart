import 'dart:async'; // Add StreamSubscription
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';
import '../../core/providers/reward_provider.dart'; // To add default rewards if needed

class MemberProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _familyId;
  String? _currentUserId;
  
  List<Member> _members = [];
  StreamSubscription<QuerySnapshot>? _membersSubscription;

  List<Member> get members => _members;

  // Membro atual (usuário logado)
  Member? get currentMember {
    if (_currentUserId == null) return null;
    try {
      return _members.firstWhere((m) => m.userId == _currentUserId);
    } catch (_) {
      return _members.isNotEmpty ? _members.first : null;
    }
  }

  // --- GUARDS DE PERMISSÃO ---
  bool canInviteMembers() => currentMember?.role == 'admin';
  bool canRemoveMember(Member target) {
    final me = currentMember;
    if (me == null) return false;
    if (me.role != 'admin') return false;
    return target.userId != me.userId; // Admin não se remove
  }

  // --- INIT (chamado após login) ---
  void init(String familyId, String userId) {
    if (_familyId == familyId && _currentUserId == userId) return;
    _familyId = familyId;
    _currentUserId = userId;
    _subscribeToMembers();
  }

  MemberProvider();

  // --- MIGRAÇÃO ---
  Future<void> _migrateLocalDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool migrated = prefs.getBool('members_migrated_to_firestore') ?? false;

    if (!migrated) {
      if (prefs.containsKey('members_data')) {
        final String data = prefs.getString('members_data')!;
        try {
          final List<dynamic> decodedList = jsonDecode(data);
          final List<Member> localMembers = decodedList.map((item) => Member.fromMap(item)).toList();

          if (localMembers.isNotEmpty) {
            print("🚀 Migrando ${localMembers.length} membros locais para o Firestore...");
            final batch = _firestore.batch();
            final membersCollection = _firestore.collection('families').doc(_familyId).collection('members');

            for (var member in localMembers) {
              // Usa o ID existente ou gera um novo se for muito simples
              final docRef = membersCollection.doc(member.id);
              batch.set(docRef, member.toMap());
            }

            await batch.commit();
            print("✅ Migração concluída!");
          }
        } catch (e) {
          print("❌ Erro na migração: $e");
        }
      }
      // Marca como migrado para não fazer de novo
      await prefs.setBool('members_migrated_to_firestore', true);
    }
  }

  void _subscribeToMembers() {
    _membersSubscription?.cancel();
    if (_familyId == null) return;

    _membersSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('members')
        .snapshots()
        .listen((snapshot) {
      _members = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['joinedAt'] is Timestamp) {
           data['joinedAt'] = (data['joinedAt'] as Timestamp).toDate().toIso8601String();
        }
        return Member.fromMap(data);
      }).toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Erro no Stream de Membros: $e');
    });
  }
  
  @override
  void dispose() {
    _membersSubscription?.cancel();
    super.dispose();
  }

  // --- AÇÕES (Agora no Firestore) ---

  Future<void> addMember(String name, String color,
      {String role = 'adult', String relationship = 'Outro'}) async {
    if (_familyId == null) return;
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMember = Member(
      id: newId,
      userId: newId,
      familyId: _familyId!,
      name: name,
      role: role,
      color: color,
      joinedAt: DateTime.now(),
      relationship: relationship,
    );
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('members')
        .doc(newMember.id)
        .set(newMember.toMap());
  }

  // --- GAMIFICATION (Agora Atualiza Firestore) ---
  
  // Retorna Future<bool> agora por ser async
  Future<bool> addXp(String memberId, int xpAmount) async {
    // Busca referência do doc
    final memberRef = _firestore.collection('families').doc(_familyId).collection('members').doc(memberId);
    
    // Usar transaction para ler e atualizar atomicamente (evitar race conditions)
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(memberRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data()!;
      if (data['joinedAt'] is Timestamp) {
           data['joinedAt'] = (data['joinedAt'] as Timestamp).toDate().toIso8601String();
      }
      final member = Member.fromMap(data);

      int newXp = member.xp + xpAmount;
      int newLevel = _calculateLevel(newXp);
      bool leveledUp = newLevel > member.level;

      transaction.update(memberRef, {
        'xp': newXp,
        'level': newLevel,
      });

      return leveledUp;
    });
  }

  // spendCoins removido. Use BankProvider.addTransaction para debitar.

  Future<void> unlockBadge(String memberId, String badgeId) async {
    final memberRef = _firestore.collection('families').doc(_familyId).collection('members').doc(memberId);
    
    // FieldValue.arrayUnion é perfeito para listas únicas no Firestore
    await memberRef.update({
      'badges': FieldValue.arrayUnion([badgeId])
    });
  }

  int _calculateLevel(int xp) {
    return 1 + (xp ~/ 1000);
  }

  // --- ATUALIZAR MEMBRO GENÉRICO ---
  Future<void> updateMember(Member updatedMember) async {
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('members')
        .doc(updatedMember.id)
        .update(updatedMember.toMap());
  }

  Future<void> removeMember(String id) async {
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('members')
        .doc(id)
        .delete();
  }

  // Métodos de Persistência Local (saveMembers/loadMembers) removidos pois agora é cloud-first.
}