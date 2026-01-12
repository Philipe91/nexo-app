class Cycle {
  final String id;
  final String memberId; // Vincula ao membro
  final DateTime lastPeriodDate;
  final int cycleLength; // Padrão 28
  final int periodLength; // Padrão 5

  Cycle({
    required this.id,
    required this.memberId,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.periodLength,
  });

  // Salvar (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
    };
  }

  // Carregar (JSON)
  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      lastPeriodDate: DateTime.parse(map['lastPeriodDate']),
      cycleLength: map['cycleLength'] ?? 28,
      periodLength: map['periodLength'] ?? 5,
    );
  }
}