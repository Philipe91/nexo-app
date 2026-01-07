import 'package:flutter/material.dart';

class ResponsibilitiesScreen extends StatelessWidget {
  const ResponsibilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Responsabilidades"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2C3E50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ResponsibilityCard(title: "Pagar Escola", lembra: "Mãe", decide: "Pai", executa: "Pai"),
          SizedBox(height: 12),
          ResponsibilityCard(title: "Compras da Semana", lembra: "Pai", decide: "Ambos", executa: "Mãe"),
          SizedBox(height: 12),
          ResponsibilityCard(title: "Agendar Pediatra", lembra: "Mãe", decide: "Mãe", executa: "Mãe"),
        ],
      ),
    );
  }
}

class ResponsibilityCard extends StatelessWidget {
  final String title;
  final String lembra;
  final String decide;
  final String executa;

  const ResponsibilityCard({super.key, required this.title, required this.lembra, required this.decide, required this.executa});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoleBadge(label: "Lembra", value: lembra, color: Colors.orange.shade100, textColor: Colors.orange.shade900),
                _RoleBadge(label: "Decide", value: decide, color: Colors.blue.shade100, textColor: Colors.blue.shade900),
                _RoleBadge(label: "Executa", value: executa, color: Colors.green.shade100, textColor: Colors.green.shade900),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _RoleBadge({required this.label, required this.value, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
        ),
      ],
    );
  }
}