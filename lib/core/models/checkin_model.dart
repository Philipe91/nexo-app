class CheckIn {
  final String id;
  final DateTime date;
  // Mapa de ID do membro -> Nível de Sentimento (1=Bem, 2=Médio, 3=Mal)
  final Map<String, int> feelings;
  // Carga total da casa naquele dia (para comparação futura)
  final int totalLoadSnapshot;

  CheckIn({
    required this.id,
    required this.date,
    required this.feelings,
    required this.totalLoadSnapshot,
  });

  // Salvar no Banco (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'feelings': feelings,
      'totalLoadSnapshot': totalLoadSnapshot,
    };
  }

  // Ler do Banco (JSON)
  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      feelings: Map<String, int>.from(map['feelings'] ?? {}),
      totalLoadSnapshot: map['totalLoadSnapshot'] ?? 0,
    );
  }
}