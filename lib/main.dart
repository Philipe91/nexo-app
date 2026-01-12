import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/member_provider.dart';
import 'core/providers/agreement_provider.dart';
import 'core/providers/checkin_provider.dart';
import 'core/providers/preferences_provider.dart'; // Fase 9
import 'core/providers/cycle_provider.dart'; // <--- O NOVO (Bio-Ritmo)

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => CheckInProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()), // Fase 9
        ChangeNotifierProvider(create: (_) => CycleProvider()), // <--- Adicionado
      ],
      child: const NexoApp(),
    ),
  );
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Garante que o PreferencesProvider existe antes de usar
    final prefs = context.watch<PreferencesProvider>();

    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      
      // Configuração de Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: prefs.themeMode,
      
      routerConfig: router,
    );
  }
}