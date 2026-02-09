import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- ARQUIVO DE ROTAS ---
import 'router.dart';

// --- IMPORTS DOS PROVIDERS ---
import 'core/theme/app_theme.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/member_provider.dart';
import 'core/providers/cycle_provider.dart';
import 'core/providers/agreement_provider.dart';
import 'core/providers/preferences_provider.dart';

// --- ARQUIVO GERADO PELO FLUTTERFIRE ---
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INICIALIZAÇÃO DO FIREBASE ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ SUCESSO: Firebase Inicializado!");
  } catch (e) {
    print("❌ ERRO NO FIREBASE: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
      ],
      // Inicia pela Splash Screen que fará o roteamento inteligente
      child: const NexoApp(initialLocation: '/splash'),
    ),
  );
}

class NexoApp extends StatelessWidget {
  final String initialLocation;

  const NexoApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    // Acessa o provider de preferências para o tema
    final preferences = Provider.of<PreferencesProvider>(context);

    // Cria o router usando a configuração centralizada
    final router = createAppRouter(initialLocation: initialLocation);

    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      
      // TEMA DINÂMICO
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // LOCALIZAÇÃO (PT-BR)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      
      routerConfig: router,
    );
  }
}