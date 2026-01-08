import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddResponsibilityScreen extends StatefulWidget {
  const AddResponsibilityScreen({super.key});

  @override
  State<AddResponsibilityScreen> createState() => _AddResponsibilityScreenState();
}

class _AddResponsibilityScreenState extends State<AddResponsibilityScreen> {
  final _formKey = GlobalKey<FormState>();

  // DADOS DO FORMULÁRIO
  String title = "";
  String quemLembra = "Mãe";
  String quemDecide = "Pai";
  String quemExecuta = "Ambos";
  String frequencia = "Semanal";
  int esforco = 1; // 1 = Leve, 2 = Médio, 3 = Pesado

  // MOCKS (Futuramente virão do banco de dados)
  final List<String> roles = ["Mãe", "Pai", "Ambos", "Filhos"];
  final List<String> frequencias = ["Diário", "Semanal", "Mensal", "Eventual"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("Nova Responsabilidade", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 1. O QUE É?
            Text("O que precisa ser gerenciado?", 
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Ex: Agendar Pediatra, Pagar Luz...",
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Icon(Icons.edit_note, color: theme.colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, dê um nome.' : null,
              onChanged: (value) => title = value,
            ),
            
            const SizedBox(height: 32),

            // 2. A TRINDADE (Mental Load)
            Row(
              children: [
                Icon(Icons.psychology, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text("Definição de Papéis", 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.onSurface
                  )),
              ],
            ),
            const SizedBox(height: 12),
            
            // Card agrupando os papéis
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdownRow(theme, "🧠 Quem Lembra?", "Carga Mental", quemLembra, (val) => setState(() => quemLembra = val!)),
                  Divider(color: Colors.grey.shade100, height: 24),
                  _buildDropdownRow(theme, "⚖️ Quem Decide?", "Autoridade", quemDecide, (val) => setState(() => quemDecide = val!)),
                  Divider(color: Colors.grey.shade100, height: 24),
                  _buildDropdownRow(theme, "💪 Quem Executa?", "Mão na Massa", quemExecuta, (val) => setState(() => quemExecuta = val!)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. DETALHES TÉCNICOS
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Frequência", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: frequencia,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: theme.colorScheme.surface, 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                        ),
                        items: frequencias.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (val) => setState(() => frequencia = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Esforço", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: esforco,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: theme.colorScheme.surface, 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("🟢 Leve")),
                          DropdownMenuItem(value: 2, child: Text("🟡 Médio")),
                          DropdownMenuItem(value: 3, child: Text("🔴 Pesado")),
                        ],
                        onChanged: (val) => setState(() => esforco = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 4. BOTÃO DE AÇÃO
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saveTask,
                style: FilledButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("CRIAR RESPONSABILIDADE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar melhorado
  Widget _buildDropdownRow(ThemeData theme, String label, String sublabel, String currentValue, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(sublabel, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
          ],
        ),
        SizedBox(
          width: 130,
          child: DropdownButtonFormField<String>(
            value: currentValue,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
            items: roles.map((role) {
              return DropdownMenuItem(
                value: role, 
                child: Text(role, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary))
              );
            }).toList(),
            onChanged: onChanged,
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Simulação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✨ Responsabilidade criada! ($quemLembra lembra, $quemExecuta faz)"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }
}