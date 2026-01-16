import 'package:cloud_firestore/cloud_firestore.dart';

class Family {
  final String id;
  final String name;
  final String inviteCode; // Código simples para convite (ex: "A1B2C3")
  final DateTime createdAt;

  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Family.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    final createdAtRaw = data['createdAt'];
    DateTime createdAt;

    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Family(
      id: doc.id,
      name: (data['name'] ?? 'Minha Família') as String,
      inviteCode: (data['inviteCode'] ?? '') as String,
      createdAt: createdAt,
    );
  }
}
