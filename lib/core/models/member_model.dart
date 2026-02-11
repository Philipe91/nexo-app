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
  final List<String> badges;

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
    this.badges = const [],
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
      'badges': badges,
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
      badges: List<String>.from(map['badges'] ?? []),
    );
  }
}