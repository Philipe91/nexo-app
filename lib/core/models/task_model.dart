class Task {
  final String id;
  final String title;
  final String whoRemembers; // Quem lembra
  final String whoDecides;   // Quem decide
  final String whoExecutes;  // Quem executa
  final int effort;          // 1, 2 ou 3
  final String frequency;    // Diário, Semanal...
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.whoRemembers,
    required this.whoDecides,
    required this.whoExecutes,
    required this.effort,
    required this.frequency,
    required this.createdAt,
  });
}