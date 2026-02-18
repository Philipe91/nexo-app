import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers/bank_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/savings_goal_model.dart';
import '../../core/widgets/glass_card.dart';

class BankScreen extends StatelessWidget {
  final String kidId;

  const BankScreen({super.key, required this.kidId});

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final bankProvider = context.watch<BankProvider>();
    
    // Garantir que o membro existe
    final kid = memberProvider.members.firstWhere((m) => m.id == kidId, orElse: () => memberProvider.members.first);
    final transactions = bankProvider.getTransactionsForKid(kidId);
    final goals = bankProvider.getGoalsForKid(kidId);

    // Formatar moeda
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'N\$');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Fundo suave
      appBar: AppBar(
        title: Text("Meu Banco 🏦", style: GoogleFonts.fredoka(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. CARTÃO DE SALDO
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(int.parse(kid.color)), Color(int.parse(kid.color)).withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                   BoxShadow(color: Color(int.parse(kid.color)).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
                ]
              ),
              child: Stack(
                children: [
                   Positioned(right: -20, top: -20, child: Icon(Icons.account_balance_wallet, size: 150, color: Colors.white.withOpacity(0.1))),
                   Padding(
                     padding: const EdgeInsets.all(24.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text("Saldo Atual", style: TextStyle(color: Colors.white70, fontSize: 16)),
                         const SizedBox(height: 8),
                         Text(
                           currencyFormat.format(kid.coins), 
                           style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)
                          ),
                         const Spacer(),
                         Row(
                           children: [
                             Icon(Icons.person, color: Colors.white.withOpacity(0.8), size: 16),
                             const SizedBox(width: 4),
                             Text(kid.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                           ],
                         )
                       ],
                     ),
                   )
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. METAS (COFRINHOS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Meus Cofrinhos 🐷", style: GoogleFonts.fredoka(fontSize: 20, color: Colors.grey[800])),
                IconButton(
                  onPressed: () => _showAddGoalDialog(context, kidId),
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            if (goals.isEmpty)
              _buildEmptyState("Sem metas ainda. Crie uma para começar a poupar!", Icons.savings_outlined)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassCard(
                      child: InkWell(
                        onTap: () => _showGoalDetails(context, goal, kid.coins.toDouble()),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(goal.icon, color: Colors.amber[800], size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation(Color(int.parse(kid.color))),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${currencyFormat.format(goal.currentAmount)} de ${currencyFormat.format(goal.targetAmount)}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    )
                                  ],
                                ),
                              ),
                              if (progress >= 1.0)
                                const Icon(Icons.check_circle, color: Colors.green)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),

            // 3. EXTRATO (HISTÓRICO)
            Text("Extrato", style: GoogleFonts.fredoka(fontSize: 20, color: Colors.grey[800])),
             const SizedBox(height: 16),
             
             if (transactions.isEmpty)
               _buildEmptyState("Nenhuma movimentação recente.", Icons.receipt_long)
             else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.take(10).length, // Mostrar só as últimas 10
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isCredit = tx.type == 'credit';
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? Colors.green : Colors.red,
                        size: 18,
                      ),
                    ),
                    title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd/MM HH:mm').format(tx.date)),
                    trailing: Text(
                      "${isCredit ? '+' : '-'} ${currencyFormat.format(tx.amount)}",
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, String kidId) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nova Meta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "O que você quer comprar?", icon: Icon(Icons.shopping_bag)),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Quanto custa?", icon: Icon(Icons.attach_money)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
               if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                 context.read<BankProvider>().addGoal(
                   kidId, 
                   titleController.text, 
                   double.tryParse(amountController.text) ?? 0, 
                   Icons.star.codePoint
                 );
                 Navigator.pop(ctx);
               }
            }, 
            child: const Text("Criar Meta")
          ),
        ],
      ),
    );
  }
  
  void _showGoalDetails(BuildContext context, SavingsGoal goal, double currentBalance) {
    final depositController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(goal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Saldo na meta: N\$ ${goal.currentAmount}"),
            const SizedBox(height: 16),
            const Text("Adicionar dinheiro à meta:"),
            TextField(
              controller: depositController,
              decoration: const InputDecoration(labelText: "Valor", prefixText: "N\$ "),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text("Seu saldo disponível: N\$ $currentBalance", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          if (goal.currentAmount > 0)
            TextButton(
              onPressed: () async {
                 // Resgatar tudo (Botão de emergência ou desistência)
                 await context.read<BankProvider>().withdrawFromGoal(goal.id, goal.currentAmount, goal.kidId);
                 
                 // Atualizar saldo local (Devolver dinheiro para a carteira)
                 context.read<MemberProvider>().addXpAndCoins(goal.kidId, 0, goal.currentAmount.toInt());

                 Navigator.pop(ctx);
              }, 
              child: const Text("Resgatar")
            ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(depositController.text) ?? 0;
              if (amount > 0 && amount <= currentBalance) {
                await context.read<BankProvider>().addFundsToGoal(goal.id, amount, goal.kidId);
                
                // Atualizar saldo local (Debitar da carteira)
                context.read<MemberProvider>().spendCoins(goal.kidId, amount.toInt());

                 Navigator.pop(ctx);
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saldo insuficiente ou valor inválido.")));
              }
            },
            child: const Text("Depositar"),
          ),
        ],
      ),
    );
  }
}
