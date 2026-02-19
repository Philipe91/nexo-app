import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/reward_provider.dart';
import '../../core/providers/bank_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/widgets/glass_card.dart';

class RewardsScreen extends StatelessWidget {
  final String kidId;

  const RewardsScreen({super.key, required this.kidId});

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final memberProvider = context.watch<MemberProvider>();
    
    final kid = memberProvider.members.firstWhere((m) => m.id == kidId, orElse: () => memberProvider.members.first);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("Loja de Prêmios", style: GoogleFonts.fredoka(color: Colors.white, fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text("💰", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text("${kid.coins}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          )
        ],
      ),
      body: rewardProvider.availableRewards.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text("A loja está vazia!", style: GoogleFonts.fredoka(fontSize: 20, color: Colors.grey)),
                const Text("Peça para seus pais adicionarem prêmios.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: rewardProvider.availableRewards.length,
            itemBuilder: (context, index) {
              final reward = rewardProvider.availableRewards[index];
              final canAfford = kid.coins >= reward.cost;

              return GlassCard(
                color: Colors.white,
                opacity: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(reward.icon, style: const TextStyle(fontSize: 48)), // Emoji
                      const SizedBox(height: 12),
                      Text(
                        reward.name, 
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: canAfford 
                          ? () => _buyReward(context, reward.id, reward.cost, reward.name) 
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("💰 ${reward.cost}"),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'kid_rewards_fab',
        onPressed: () => _showSuggestionDialog(context),
        label: const Text("Sugerir Prêmio"),
        icon: const Icon(Icons.lightbulb),
        backgroundColor: Colors.amber,
      ),

    );
  }

  void _showSuggestionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sugerir Prêmio 💡"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "O que você quer?", hintText: "Ex: Ir ao parque"),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: "Quanto deve custar?", suffixText: "💰"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(labelText: "Escolha um emoji", hintText: "🎢"),
              maxLength: 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final cost = int.tryParse(costController.text) ?? 50;
              final icon = iconController.text.trim().isEmpty ? '🎁' : iconController.text.trim();

              if (name.isNotEmpty) {
                 context.read<RewardProvider>().addReward(name, cost, icon, isApproved: false);
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Sugestão enviada para seus pais!"))
                 );
              }
            },
            child: const Text("Enviar"),
          )
        ],
      ),
    );
  }

  void _buyReward(BuildContext context, String rewardId, int cost, String rewardName) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Comprar Prêmio?"),
        content: Text("Deseja gastar $cost moedas em '$rewardName'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              // Debita via transação (BankProvider atualiza saldo)
              await context.read<BankProvider>().addTransaction(
                kidId, 
                cost.toDouble(), 
                "Compra: $rewardName", 
                "debit"
              );
              
              Navigator.pop(context);
              
              // Sucesso (Assumindo que transação funciona. Idealmente checar erro)
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("🎉 Compra Realizada!"),
                    content: Text("Aproveite seu prêmio!"),
                    icon: Icon(Icons.check_circle, color: Colors.green, size: 50),
                  )
                );
              }
            }, 
            child: const Text("Comprar")
          ),
        ],
      )
    );
  }
}
