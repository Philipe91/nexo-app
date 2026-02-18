import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/bank_provider.dart';
import '../../core/widgets/glass_card.dart';

class BankManagerScreen extends StatelessWidget {
  const BankManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final bankProvider = context.watch<BankProvider>();
    
    // Filtrar apenas crianças (role != adult ?) ou todos dependendo da regra.
    // Vamos assumir role != 'adult' para simplificar ou quem tem relationship Filho/Filha
    final kids = memberProvider.members.where((m) => m.role == 'child').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Banco"),
        centerTitle: true,
      ),
      body: kids.isEmpty 
        ? const Center(child: Text("Nenhuma criança cadastrada."))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: kids.length,
            itemBuilder: (context, index) {
              final kid = kids[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(int.parse(kid.color)),
                              child: Text(kid.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Text(kid.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text("N\$ ${kid.coins}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showTransactionDialog(context, kid.id, 'Pagar Mesada', true),
                              icon: const Icon(Icons.attach_money, color: Colors.green),
                              label: const Text("Pagar Mesada"),
                            ),
                             TextButton.icon(
                              onPressed: () => _showTransactionDialog(context, kid.id, 'Correção/Bônus', true),
                              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                              label: const Text("Bônus"),
                            ),
                             TextButton.icon(
                              onPressed: () => _showTransactionDialog(context, kid.id, 'Penalidade', false),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              label: const Text("Débito"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showTransactionDialog(BuildContext context, String kidId, String defaultDesc, bool isCredit) {
    final amountController = TextEditingController();
    final descController = TextEditingController(text: defaultDesc);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCredit ? "Adicionar Crédito" : "Debitar Valor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Valor (N\$)", border: OutlineInputBorder()),
               keyboardType: TextInputType.number,
               autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Descrição", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isCredit ? Colors.green : Colors.red),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                // 1. Registrar Transação no Firestore
                context.read<BankProvider>().addTransaction(
                  kidId, 
                  amount, 
                  descController.text, 
                  isCredit ? 'credit' : 'debit'
                );

                // 2. Atualizar Saldo Localmente
                if (isCredit) {
                  context.read<MemberProvider>().addXpAndCoins(kidId, 0, amount.toInt());
                } else {
                  context.read<MemberProvider>().spendCoins(kidId, amount.toInt());
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transação realizada com sucesso!")));
              }
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
