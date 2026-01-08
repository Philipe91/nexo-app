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

  // LISTAS DE OPÇÕES (Mocks)
  final List<String> roles = ["Mãe", "Pai", "Ambos", "Filhos"];
  final List<String> frequencias = ["Diário", "Semanal", "Mensal", "Eventual"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Fundo neutro e calmo
      appBar: AppBar(
        title: const Text("Nova Responsabilidade"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 1. O QUE É?
            const Text("O que precisa ser gerenciado?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Ex: Agendar Pediatra, Pagar Luz...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, dê um nome.' : null,
              onChanged: (value) => title = value,
            ),
            
            const SizedBox(height: 30),

            // 2. A TRINDADE (Mental Load)
            const Text("Definição de Papéis (A Mágica do NEXO)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))),
            const SizedBox(height: 10),
            
            // Card agrupando os papéis para ficar visualmente limpo
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDropdownRow("🧠 Quem Lembra?", "Carga Mental", quemLembra, (val) => setState(() => quemLembra = val!)),
                  const Divider(),
                  _buildDropdownRow("⚖️ Quem Decide?", "Autoridade", quemDecide, (val) => setState(() => quemDecide = val!)),
                  const Divider(),
                  _buildDropdownRow("💪 Quem Executa?", "Mão na Massa", quemExecuta, (val) => setState(() => quemExecuta = val!)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. DETALHES TÉCNICOS (Frequência e Esforço)
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
                        decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        items: frequencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
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
                      const Text("Nível de Esforço", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: esforco,
                        decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
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
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveTask,
                child: const Text("CRIAR RESPONSABILIDADE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para deixar o código limpo
  Widget _buildDropdownRow(String label, String sublabel, String currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(sublabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<String>(
              value: currentValue,
              decoration: const InputDecoration(border: InputBorder.none),
              items: roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))));
              }).toList(),
              onChanged: onChanged,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Simulação de salvamento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Criado: $title ($frequencia)"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }
}