import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/widgets/glass_card.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // Armazena o sentimento de cada membro (ID -> Sentimento)
  // 1 = Bem, 2 = Médio, 3 = Mal
  final Map<String, int> _feelings = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberProvider = context.watch<MemberProvider>();
    final taskProvider = context.watch<TaskProvider>();
    
    final members = memberProvider.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-in Semanal"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: members.isEmpty
          ? const Center(child: Text("Adicione membros primeiro."))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  "Como foi a semana?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Avaliem a carga mental de cada um para calibrar a próxima semana.",
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Lista de Membros para Avaliação
                ...members.map((member) {
                  // Calcula a carga real dessa pessoa
                  final stats = taskProvider.calculateMentalLoad(member.name);
                  final load = stats['total'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassCard(
                      color: Colors.white,
                      opacity: 0.8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Cabeçalho do Card (Nome e Carga Real)
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  child: Text(member.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text("Carga Atual: $load pontos", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text("Como se sentiu?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 12),
                            
                            // Botões de Sentimento
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _FeelingButton(
                                  emoji: "😌",
                                  label: "Leve",
                                  isSelected: _feelings[member.id] == 1,
                                  color: Colors.green,
                                  onTap: () => setState(() => _feelings[member.id] = 1),
                                ),
                                _FeelingButton(
                                  emoji: "😐",
                                  label: "Ok",
                                  isSelected: _feelings[member.id] == 2,
                                  color: Colors.orange,
                                  onTap: () => setState(() => _feelings[member.id] = 2),
                                ),
                                _FeelingButton(
                                  emoji: "😫",
                                  label: "Pesado",
                                  isSelected: _feelings[member.id] == 3,
                                  color: Colors.red,
                                  onTap: () => setState(() => _feelings[member.id] = 3),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Botão Finalizar
                FilledButton.icon(
                  onPressed: _finishCheckIn,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Concluir Check-in"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
    );
  }

  void _finishCheckIn() {
    // Por enquanto, apenas fecha e dá um feedback visual.
    // Futuramente, salvaremos isso num "Histórico".
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Check-in realizado! Ciclo reiniciado mentalmente."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}

// Widget auxiliar pequeno para os botões de emoji
class _FeelingButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FeelingButton({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}