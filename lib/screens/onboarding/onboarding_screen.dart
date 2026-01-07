import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_moon, size: 80, color: Color(0xFF2C3E50)),
            const SizedBox(height: 20),
            const Text("NEXO", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Clareza para a rotina da família.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text("COMEÇAR"),
            ),
          ],
        ),
      ),
    );
  }
}