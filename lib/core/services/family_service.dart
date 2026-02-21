import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Gera um código de convite único de 6 caracteres (ex: NEXO42)
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// CRIAR FAMÍLIA — chamado pelo Admin no FamilySetupScreen
  /// Retorna o familyId criado
  Future<String> createFamily({
    required String familyName,
    required String adminName,
    required String adminColor,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Usuário não autenticado');

    final inviteCode = _generateInviteCode();

    // 1. Cria o documento da família
    final familyRef = await _db.collection('families').add({
      'name': familyName,
      'inviteCode': inviteCode,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Cria o membro Admin nessa família
    await familyRef.collection('members').doc(uid).set({
      'id': uid,
      'userId': uid,
      'familyId': familyRef.id,
      'name': adminName,
      'role': 'admin',
      'color': adminColor,
      'joinedAt': FieldValue.serverTimestamp(),
      'xp': 0,
      'level': 1,
      'coins': 0,
      'badges': [],
      'relationship': 'Outro',
    });

    // 3. Vincula o familyId ao perfil do usuário no Firestore
    await _db.collection('users').doc(uid).update({
      'currentFamilyId': familyRef.id,
      'role': 'admin',
    });

    return familyRef.id;
  }

  /// ENTRAR NA FAMÍLIA — chamado pelo convidado com o código
  /// Retorna o familyId encontrado
  Future<String> joinFamily({
    required String inviteCode,
    required String memberName,
    required String memberColor,
    required String role, // 'adult' ou 'child'
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Usuário não autenticado');

    // 1. Busca família pelo código (case-insensitive)
    final query = await _db
        .collection('families')
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Código inválido. Verifique e tente novamente.');
    }

    final familyDoc = query.docs.first;
    final familyId = familyDoc.id;

    // 2. Cria o membro na família
    await familyDoc.reference.collection('members').doc(uid).set({
      'id': uid,
      'userId': uid,
      'familyId': familyId,
      'name': memberName,
      'role': role,
      'color': memberColor,
      'joinedAt': FieldValue.serverTimestamp(),
      'xp': 0,
      'level': 1,
      'coins': 0,
      'badges': [],
      'relationship': 'Outro',
    });

    // 3. Vincula o familyId ao perfil do usuário
    await _db.collection('users').doc(uid).update({
      'currentFamilyId': familyId,
      'role': role,
    });

    return familyId;
  }

  /// Retorna o código de convite da família atual
  Future<String?> getInviteCode(String familyId) async {
    final doc = await _db.collection('families').doc(familyId).get();
    return doc.data()?['inviteCode'] as String?;
  }

  /// Stream de membros da família em tempo real
  Stream<List<Map<String, dynamic>>> membersStream(String familyId) {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
