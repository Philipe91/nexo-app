import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

void main() {
  runApp(const NexoApp());
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      
      // AQUI ESTAVA O ERRO (Faltava a vírgula no final da linha)
      theme: AppTheme.lightTheme, 
      
      routerConfig: router,
    );
  }
}