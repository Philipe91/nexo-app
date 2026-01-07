import 'package:flutter/material.dart';

class ResponsibilitiesScreen extends StatelessWidget {
  const ResponsibilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Responsabilidades")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(child: ListTile(title: Text("Pagar Conta de Luz"), subtitle: Text("Quem Lembra: Pai • Quem Executa: Mãe"))),
          Card(child: ListTile(title: Text("Mercado Semanal"), subtitle: Text("Quem Lembra: Mãe • Quem Executa: Ambos"))),
        ],
      ),
    );
  }
}