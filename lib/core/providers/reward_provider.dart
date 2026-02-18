import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardProvider extends ChangeNotifier {
  List<Reward> _rewards = [];
  StreamSubscription<QuerySnapshot>? _rewardsSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // TODO: Usar ID real da família
  String get _familyId => 'default_family'; 

  List<Reward> get rewards => _rewards;
  
  // Prêmios visíveis na loja (Aprovados)
  List<Reward> get availableRewards => _rewards.where((r) => r.isApproved).toList();

  // Sugestões pendentes (Para os pais aprovarem)
  List<Reward> get pendingRewards => _rewards.where((r) => !r.isApproved).toList();

  RewardProvider() {
    subscribeToRewards();
  }

  void subscribeToRewards() {
    _rewardsSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('rewards')
        .snapshots()
        .listen((snapshot) {
      _rewards = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Reward.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _rewardsSubscription?.cancel();
    super.dispose();
  }

  // --- AÇÕES ---

  Future<void> addReward(String name, int cost, String icon, {bool isApproved = true}) async {
    final newReward = Reward(
      id: '',
      name: name,
      cost: cost,
      icon: icon,
      isApproved: isApproved,
    );
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('rewards')
        .add(newReward.toMap());
  }

  Future<void> approveReward(String id) async {
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('rewards')
        .doc(id)
        .update({'isApproved': true});
  }

  Future<void> deleteReward(String id) async {
    await _firestore
        .collection('families')
        .doc(_familyId)
        .collection('rewards')
        .doc(id)
        .delete();
  }
}
