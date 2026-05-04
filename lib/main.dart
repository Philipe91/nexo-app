import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- ARQUIVO DE ROTAS ---
import 'router.dart';

// --- IMPORTS DOS PROVIDERS ---
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/assistant_provider.dart'; // <--- Import Novo // <--- Import AuthProvider
import 'core/providers/task_provider.dart';
import 'core/providers/member_provider.dart';
import 'core/providers/cycle_provider.dart';
import 'core/providers/agreement_provider.dart';
import 'core/providers/preferences_provider.dart';
import 'core/providers/shopping_provider.dart';
import 'core/providers/reward_provider.dart'; 
import 'core/providers/bank_provider.dart';
import 'core/providers/mental_load_provider.dart'; // <--- Import Novo
import 'core/providers/handoff_provider.dart';
import 'core/services/notification_service.dart';

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

    // --- INICIALIZAÇÃO DAS NOTIFICAÇÕES ---
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();
    print("✅ SUCESSO: Notificações Inicializadas!");

  } catch (e) {
    print("❌ ERRO NO FIREBASE: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        // Auth é base — sempre primeiro
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AssistantProvider()),

        // TaskProvider e MemberProvider dependem do AuthProvider para obter familyId real
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, auth, task) {
            final t = task ?? TaskProvider();
            if (auth.hasFamily && auth.appUser != null && auth.firebaseUser != null) {
              t.init(auth.appUser!.currentFamilyId!, auth.firebaseUser!.uid);
            }
            return t;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, MemberProvider>(
          create: (_) => MemberProvider(),
          update: (_, auth, member) {
            final m = member ?? MemberProvider();
            if (auth.hasFamily && auth.appUser != null && auth.firebaseUser != null) {
              m.init(auth.appUser!.currentFamilyId!, auth.firebaseUser!.uid);
            }
            return m;
          },
        ),

        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => MentalLoadProvider()),

        // Handoff (passar o bastão) — depende do AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, HandoffProvider>(
          create: (_) => HandoffProvider(),
          update: (_, auth, handoff) {
            final h = handoff ?? HandoffProvider();
            if (auth.hasFamily && auth.appUser != null && auth.firebaseUser != null) {
              h.init(auth.appUser!.currentFamilyId!, auth.firebaseUser!.uid);
            }
            return h;
          },
        ),
      ],
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