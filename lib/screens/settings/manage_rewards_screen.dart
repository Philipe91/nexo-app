import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/reward_provider.dart';
import '../../core/models/reward_model.dart';
import '../../core/widgets/glass_card.dart';

class ManageRewardsScreen extends StatefulWidget {
  const ManageRewardsScreen({super.key});

  @override
  State<ManageRewardsScreen> createState() => _ManageRewardsScreenState();
}

class _ManageRewardsScreenState extends State<ManageRewardsScreen> {
  void _showRewardDialog({Reward? reward}) {
    final nameController = TextEditingController(text: reward?.name ?? '');
    final costController = TextEditingController(text: reward?.cost.toString() ?? '50');
    final iconController = TextEditingController(text: reward?.icon ?? '🎁');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reward == null ? "Novo Prêmio" : "Editar Prêmio"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome do Prêmio", hintText: "Ex: 30min de TV"),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: "Custo (Moedas)", suffixText: "💰"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(labelText: "Ícone (Emoji)", hintText: "🧸"),
              maxLength: 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final cost = int.tryParse(costController.text) ?? 0;
              final icon = iconController.text.trim().isEmpty ? '🎁' : iconController.text.trim();

              if (name.isNotEmpty && cost > 0) {
                 context.read<RewardProvider>().addReward(name, cost, icon);
                 Navigator.pop(context);
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final pending = rewardProvider.pendingRewards;
    final approved = rewardProvider.availableRewards;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Gerenciar Loja"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manage_rewards_fab',
        onPressed: () => _showRewardDialog(),
        label: const Text("Novo Prêmio"),
        icon: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            _buildSectionHeader("Sugestões das Crianças 💡"),
            ...pending.map((r) => _buildSuggestionTile(r, rewardProvider)),
            const SizedBox(height: 24),
          ],

          _buildSectionHeader("Prêmios na Loja 🎁"),
          if (approved.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Nenhum prêmio na loja.", style: TextStyle(color: Colors.grey)),
            ),
          ...approved.map((r) => _buildRewardTile(r, rewardProvider)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
      ),
    );
  }

  Widget _buildSuggestionTile(Reward reward, RewardProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        color: Colors.orange.shade50,
        child: ListTile(
          leading: Text(reward.icon, style: const TextStyle(fontSize: 32)),
          title: Text(reward.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${reward.cost} Moedas"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => provider.deleteReward(reward.id),
                tooltip: "Rejeitar",
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => provider.approveReward(reward.id),
                tooltip: "Aprovar",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardTile(Reward reward, RewardProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        color: Colors.white,
        child: ListTile(
          leading: Text(reward.icon, style: const TextStyle(fontSize: 32)),
          title: Text(reward.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${reward.cost} Moedas"),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () => provider.deleteReward(reward.id),
          ),
          onTap: () => _showRewardDialog(reward: reward),
        ),
      ),
    );
  }
}
