import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Painel de Equilíbrio")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Seu Dashboard vai aqui"),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => context.push('/responsibilities'),
              child: const Text("Ver Responsabilidades"),
            ),
          ],
        ),
      ),
    );
  }
}