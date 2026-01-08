import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'router.dart'; // Importa o arquivo onde definimos o 'router'

void main() {
  runApp(const NexoApp());
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug" no canto
      theme: AppTheme.lightTheme, // Aplica o tema claro definido no projeto
      
      // CORREÇÃO: Mudamos de 'appRouter' para 'router'
      // para combinar com o nome que usamos no arquivo router.dart
      routerConfig: router, 
    );
  }
}