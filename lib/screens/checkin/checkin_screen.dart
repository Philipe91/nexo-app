import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Agora vai funcionar (depois do passo 1)
import '../../models/member_model.dart'; // <--- O IMPORT QUE FALTAVA
import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/checkin_provider.dart';
import '../../core/widgets/glass_card.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _tempFeelings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Check-in Semanal", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: "Novo Check-in"),
            Tab(text: "Histórico"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewCheckInTab(context),
          _buildHistoryTab(context),
        ],
      ),
    );
  }

  // --- ABA 1: NOVO CHECK-IN ---
  Widget _buildNewCheckInTab(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;
    final taskProvider = context.watch<TaskProvider>();

    if (members.isEmpty) {
      return const Center(child: Text("Adicione membros primeiro."));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Como foi a semana?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Avaliem a carga e o sentimento para alinhar a casa.",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        ...members.map((member) {
          final stats = taskProvider.calculateMentalLoad(member.name);
          final load = stats['total'] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                          Text("Carga: $load pts", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text("Sentimento:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FeelingButton(
                        emoji: "😌", label: "Leve", color: Colors.green,
                        isSelected: _tempFeelings[member.id] == 1,
                        onTap: () => setState(() => _tempFeelings[member.id] = 1),
                      ),
                      _FeelingButton(
                        emoji: "😐", label: "Ok", color: Colors.orange,
                        isSelected: _tempFeelings[member.id] == 2,
                        onTap: () => setState(() => _tempFeelings[member.id] = 2),
                      ),
                      _FeelingButton(
                        emoji: "😫", label: "Pesado", color: Colors.red,
                        isSelected: _tempFeelings[member.id] == 3,
                        onTap: () => setState(() => _tempFeelings[member.id] = 3),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 24),

        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: () => _submitCheckIn(context),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Registrar Check-in"),
          ),
        ),
      ],
    );
  }

  // --- ABA 2: HISTÓRICO ---
  Widget _buildHistoryTab(BuildContext context) {
    final history = context.watch<CheckInProvider>().history;
    final members = context.read<MemberProvider>().members;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Nenhum histórico ainda.", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final checkin = history[index];
        final dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(checkin.date);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: checkin.feelings.entries.map((entry) {
                    // Encontra o nome do membro pelo ID
                    final memberName = members.firstWhere(
                      (m) => m.id == entry.key, 
                      orElse: () => Member(id: '0', name: '?', color: '') // AGORA VAI FUNCIONAR
                    ).name;

                    return ListTile(
                      dense: true,
                      leading: Text(
                        _getEmoji(entry.value), 
                        style: const TextStyle(fontSize: 24)
                      ),
                      title: Text(memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: _getFeelingLabel(entry.value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitCheckIn(BuildContext context) {
    final members = context.read<MemberProvider>().members;
    
    // Validação: Todos votaram?
    if (_tempFeelings.length < members.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos os membros precisam votar!")),
      );
      return;
    }

    // Salva no Provider
    final currentTotalLoad = context.read<TaskProvider>().totalMentalLoad;
    context.read<CheckInProvider>().addCheckIn(_tempFeelings, currentTotalLoad);

    // Feedback e Muda de aba
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Check-in salvo no histórico!")),
    );
    
    // Limpa a tela e vai para o histórico
    setState(() {
      _tempFeelings.clear();
      _tabController.animateTo(1); 
    });
  }

  String _getEmoji(int level) {
    if (level == 1) return "😌";
    if (level == 2) return "😐";
    return "😫";
  }

  Widget _getFeelingLabel(int level) {
    String text;
    Color color;
    if (level == 1) { text = "Leve"; color = Colors.green; }
    else if (level == 2) { text = "Médio"; color = Colors.orange; }
    else { text = "Pesado"; color = Colors.red; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

// Botãozinho customizado de emoji
class _FeelingButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FeelingButton({
    required this.emoji, required this.label, required this.isSelected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey)),
          ],
        ),
      ),
    );
  }
}