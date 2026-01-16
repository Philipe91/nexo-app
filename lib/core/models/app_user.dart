import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id; // UID do Firebase Auth
  final String email;
  final String? name;
  final String? currentFamilyId; // Atalho para saber qual família abrir
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.currentFamilyId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'currentFamilyId': currentFamilyId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    final createdAtRaw = data['createdAt'];
    DateTime createdAt;

    // Blindado: aceita Timestamp/DateTime/String/null
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return AppUser(
      id: doc.id,
      email: (data['email'] ?? '') as String,
      name: data['name'] as String?,
      currentFamilyId: data['currentFamilyId'] as String?,
      createdAt: createdAt,
    );
  }
}
