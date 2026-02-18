class Member {
  final String id;
  final String userId;
  final String familyId;
  final String name;
  final String role; // admin, adult, child
  final String color;
  final DateTime joinedAt;
  final int xp;
  final int level;
  final int coins;
  final List<String> badges;
  final String relationship; // Pai, Mãe, Filho, Filha, Tio, Tia, Avô, Avó, Outro

  Member({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.name,
    required this.role,
    required this.color,
    required this.joinedAt,
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.badges = const [],
    this.relationship = 'Outro',
  });

  // Converte para Mapa (Salvar no banco/local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'familyId': familyId,
      'name': name,
      'role': role,
      'color': color,
      'joinedAt': joinedAt.toIso8601String(),
      'xp': xp,
      'level': level,
      'coins': coins,
      'badges': badges,
      'relationship': relationship,
    };
  }

  // Cria a partir de Mapa (Ler do banco/local)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      familyId: map['familyId'] ?? 'local_family',
      name: map['name'] ?? '',
      role: map['role'] ?? 'adult',
      color: map['color'] ?? '0xFF4D5BCE',
      joinedAt: map['joinedAt'] != null 
          ? DateTime.parse(map['joinedAt']) 
          : DateTime.now(),
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      coins: map['coins'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      relationship: map['relationship'] ?? 'Outro',
    );
  }
}