import 'dart:async'; // Add StreamSubscription
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';
import '../../core/providers/reward_provider.dart'; // To add default rewards if needed

class MemberProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // TODO: Em um app real, usar ID da família do usuário logado
  String get _familyId => 'default_family'; 
  
  List<Member> _members = [];
  StreamSubscription<QuerySnapshot>? _membersSubscription;

  List<Member> get members => _members;

  MemberProvider() {
    _init();
  }

  Future<void> _init() async {
    // 1. Verificar se precisa migrar dados locais para o Firestore
    await _migrateLocalDataIfNeeded();
    
    // 2. Iniciar escuta do Firestore
    _subscribeToMembers();
  }

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

  // --- ESCUTAR DATA ---
  void _subscribeToMembers() {
    _membersSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('members')
        .snapshots()
        .listen((snapshot) {
      _members = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // MemberModel espera DateTime. Firestore retorna Timestamp.
        // Se o seu Member.fromMap já trata isso, ótimo. Se não, precisaríamos tratar.
        // Assumindo que Member.fromMap pode precisar de juste se não lidar com Timestamp
        if (data['joinedAt'] is Timestamp) {
           data['joinedAt'] = (data['joinedAt'] as Timestamp).toDate().toIso8601String();
        }
        return Member.fromMap(data);
      }).toList();
      notifyListeners();
    }, onError: (e) {
      print("❌ Erro no Stream de Membros: $e");
    });
  }
  
  @override
  void dispose() {
    _membersSubscription?.cancel();
    super.dispose();
  }

  // --- AÇÕES (Agora no Firestore) ---

  Future<void> addMember(String name, String color, {String role = 'adult', String relationship = 'Outro'}) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString(); // ID temp, Firestore gera se quiser
    final newMember = Member(
      id: newId, 
      userId: newId,
      familyId: _familyId,
      name: name,
      role: role,
      color: color,
      joinedAt: DateTime.now(),
      relationship: relationship,
    );
    
    // Salvar no Firestore com ID específico (ou .add() deixar gerar)
    // Vamos usar .set com ID timestamp para manter compatibilidade com IDs existentes ou .add
    // Se usarmos .doc(newMember.id).set(...), garantimos que o ID do modelo bate com o DOC.
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