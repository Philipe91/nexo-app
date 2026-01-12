import 'package:flutter/material.dart';
import '../../shared/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard da Família"),
      ),
      drawer: const CustomDrawer(), // Aqui está o nosso menu com o switch
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card de teste para ver a cor de fundo (Surface)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.verified, size: 50, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(
                      "Sistema Base Configurado",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const Text("Abra o menu lateral para testar o Modo Dark."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}