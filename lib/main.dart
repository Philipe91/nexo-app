import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/member_provider.dart'; // <--- Import Novo

void main() {
  runApp(
    // MultiProvider permite ter vários "bancos de dados" na memória
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()), // <--- Adicionado
      ],
      child: const NexoApp(),
    ),
  );
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}