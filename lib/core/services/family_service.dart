import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_model.dart';
import '../models/member_model.dart';

class FamilyService {
  FamilyService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> createFamily({
    required String creatorId,
    required String familyName,
    required String creatorName,
  }) async {
    final batch = _db.batch();

    final familyRef = _db.collection('families').doc();
    final newFamily = Family(
      id: familyRef.id,
      name: familyName.trim().isEmpty ? 'Minha Família' : familyName.trim(),
      inviteCode: _generateInviteCode(),
      createdAt: DateTime.now(),
    );

    final memberRef = familyRef.collection('members').doc(creatorId);
    final newMember = Member(
      id: creatorId,
      userId: creatorId,
      familyId: familyRef.id,
      name: creatorName.trim().isEmpty ? 'Admin' : creatorName.trim(),
      role: 'admin',
      color: '0xFF4D5BCE',
      joinedAt: DateTime.now(),
    );

    final userRef = _db.collection('users').doc(creatorId);

    batch.set(familyRef, newFamily.toMap());
    batch.set(memberRef, newMember.toMap());

    // Blindado: merge:true evita falha se doc não existir
    batch.set(
      userRef,
      {'currentFamilyId': familyRef.id},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<bool> joinFamilyByCode({
    required String userId,
    required String userName,
    required String inviteCode,
  }) async {
    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) return false;

    final query = await _db
        .collection('families')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final familyDoc = query.docs.first;
    final familyId = familyDoc.id;

    final batch = _db.batch();

    final memberRef = _db.collection('families').doc(familyId).collection('members').doc(userId);
    final newMember = Member(
      id: userId,
      userId: userId,
      familyId: familyId,
      name: userName.trim().isEmpty ? 'Adulto' : userName.trim(),
      role: 'adult',
      color: '0xFFE91E63',
      joinedAt: DateTime.now(),
    );

    final userRef = _db.collection('users').doc(userId);

    batch.set(memberRef, newMember.toMap());
    batch.set(
      userRef,
      {'currentFamilyId': familyId},
      SetOptions(merge: true),
    );

    await batch.commit();
    return true;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
