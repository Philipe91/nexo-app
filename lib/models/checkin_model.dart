class CheckIn {
  final String id;
  final DateTime date;
  final Map<String, int> feelings;
  final int totalLoadSnapshot;

  CheckIn({
    required this.id,
    required this.date,
    required this.feelings,
    required this.totalLoadSnapshot,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'feelings': feelings,
      'totalLoadSnapshot': totalLoadSnapshot,
    };
  }

  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      feelings: Map<String, int>.from(map['feelings'] ?? {}),
      totalLoadSnapshot: map['totalLoadSnapshot'] ?? 0,
    );
  }
}