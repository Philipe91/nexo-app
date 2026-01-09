import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/agreement_provider.dart';
import '../../core/widgets/glass_card.dart';

class AgreementsScreen extends StatefulWidget {
  const AgreementsScreen({super.key});

  @override
  State<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends State<AgreementsScreen> {
  // Controladores para o formulário do Diálogo
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  void _showAddDialog() {
    _titleController.clear();
    _descController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo Combinado"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Regra (Ex: Louça do Jantar)",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Detalhes (Ex: Quem cozinha não lava)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                // Salva no Provider
                context.read<AgreementProvider>().addAgreement(
                      _titleController.text,
                      _descController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text("Salvar Acordo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Escuta a lista de acordos
    final agreementProvider = context.watch<AgreementProvider>();
    final agreements = agreementProvider.agreements;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Acordos da Casa"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.gavel), // Ícone de Martelo/Regra
        label: const Text("Novo Acordo"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: agreements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handshake_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Nenhum acordo registrado.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text("Use o botão abaixo para criar regras claras."),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: agreements.length,
              itemBuilder: (context, index) {
                final agreement = agreements[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassCard(
                    color: Colors.white,
                    opacity: 0.8,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                        child: Icon(Icons.assignment_turned_in, color: theme.colorScheme.secondary),
                      ),
                      title: Text(
                        agreement.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: agreement.description.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(agreement.description),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          // Remove do Provider
                          context.read<AgreementProvider>().removeAgreement(agreement.id);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}