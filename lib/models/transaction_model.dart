class Transaction {
  final String id;
  final String kidId;
  final double amount;
  final String description; // "Tarefa: Arrumar Cama", "Compra: Sorvete"
  final DateTime date;
  final String type; // 'credit' (ganho) or 'debit' (gasto)

  Transaction({
    required this.id,
    required this.kidId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kidId': kidId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      kidId: map['kidId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      type: map['type'] ?? 'credit',
    );
  }
}
