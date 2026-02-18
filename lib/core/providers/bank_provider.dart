import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../models/transaction_model.dart';
import '../../models/savings_goal_model.dart';
import '../../core/providers/member_provider.dart';

class BankProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _familyId => 'default_family'; // Em produção, viria do AuthProvider

  List<Transaction> _transactions = [];
  List<SavingsGoal> _goals = [];

  List<Transaction> get transactions => _transactions;
  List<SavingsGoal> get goals => _goals;

  BankProvider() {
    _subscribeToData();
  }

  void _subscribeToData() {
    // TRANSAÇÕES
    _firestore
        .collection('families')
        .doc(_familyId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Lidar com Timestamp do Firestore
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        return Transaction.fromMap(data);
      }).toList();
      notifyListeners();
    });

    // METAS (GOALS)
    _firestore
        .collection('families')
        .doc(_familyId)
        .collection('savings_goals')
        .snapshots()
        .listen((snapshot) {
      _goals = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SavingsGoal.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  // --- MÉTODOS PÚBLICOS ---

  List<Transaction> getTransactionsForKid(String kidId) {
    return _transactions.where((t) => t.kidId == kidId).toList();
  }

  List<SavingsGoal> getGoalsForKid(String kidId) {
    return _goals.where((g) => g.kidId == kidId).toList();
  }

  double getBalance(String kidId) {
    // Poderíamos calcular somando transações, mas o MemberProvider já guarda o saldo atual.
    // Vamos usar as transações para histórico e extrato.
    // Se quisermos recalcular:
    /*
    double balance = 0;
    for (var t in getTransactionsForKid(kidId)) {
      if (t.type == 'credit') balance += t.amount;
      else balance -= t.amount;
    }
    return balance;
    */
    // Por enquanto, confiar no MemberProvider, mas aqui é útil para validação.
    return 0.0; // Placeholder, a UI usa MemberProvider.coins
  }

  // Adicionar Transação (Crédito ou Débito)
  Future<void> addTransaction(String kidId, double amount, String description, String type) async {
    // 1. Criar registro da transação
    final docRef = _firestore.collection('families').doc(_familyId).collection('transactions').doc();
    final newTx = Transaction(
      id: docRef.id,
      kidId: kidId,
      amount: amount,
      description: description,
      date: DateTime.now(),
      type: type,
    );
    await docRef.set(newTx.toMap());

    // 2. Atualizar saldo do membro
    // COMO O MEMBER PROVIDER É LOCAL POR ENQUANTO, NÃO VAMOS ATUALIZAR O FIRESTORE DO MEMBRO AQUI.
    // A UI DEVE CHAMAR MemberProvider.addCoins() OU MemberProvider.spendCoins() LOCALMENTE.
    
    /* 
    final memberRef = _firestore.collection('families').doc(_familyId).collection('members').doc(kidId);
    if (type == 'credit') {
      await memberRef.update({'coins': FieldValue.increment(amount.toInt())});
    } else {
      await memberRef.update({'coins': FieldValue.increment(-amount.toInt())});
    }
    */
  }

  // --- METAS ---

  Future<void> addGoal(String kidId, String title, double targetAmount, int iconCodePoint) async {
    final docRef = _firestore.collection('families').doc(_familyId).collection('savings_goals').doc();
    final newGoal = SavingsGoal(
      id: docRef.id,
      kidId: kidId,
      title: title,
      targetAmount: targetAmount,
      currentAmount: 0,
      iconCodePoint: iconCodePoint,
    );
    await docRef.set(newGoal.toMap());
  }

  Future<void> addFundsToGoal(String goalId, double amount, String kidId) async {
    // 1. Verificar se tem saldo (Isso deveria ser feito na UI ou aqui antes de prosseguir)
    // Vamos assumir que a verificação foi feita.
    
    // 2. Debitar da conta corrente (Wallet) -> Criar transação de débito
    await addTransaction(kidId, amount, "Depósito na Meta", "debit");

    // 3. Creditar na Meta
    final goalRef = _firestore.collection('families').doc(_familyId).collection('savings_goals').doc(goalId);
    await goalRef.update({'currentAmount': FieldValue.increment(amount)});
  }
  
  Future<void> withdrawFromGoal(String goalId, double amount, String kidId) async {
     // 1. Debitar da Meta
    final goalRef = _firestore.collection('families').doc(_familyId).collection('savings_goals').doc(goalId);
    await goalRef.update({'currentAmount': FieldValue.increment(-amount)});

    // 2. Creditar na conta corrente -> Transação de crédito
    await addTransaction(kidId, amount, "Resgate da Meta", "credit");
  }

  Future<void> deleteGoal(String goalId) async {
    // O que acontece com o dinheiro? Deveria voltar pro saldo.
    // Por simplificação forçamos o usuário a esvaziar antes, ou fazemos automático.
    // Vamos fazer o resgate automático se tiver saldo > 0.
    
    final goalDoc = await _firestore.collection('families').doc(_familyId).collection('savings_goals').doc(goalId).get();
    if (goalDoc.exists) {
      final goal = SavingsGoal.fromMap(goalDoc.data()!);
      if (goal.currentAmount > 0) {
        await addTransaction(goal.kidId, goal.currentAmount, "Encerramento de Meta: ${goal.title}", "credit");
      }
      await goalDoc.reference.delete();
    }
  }
}
