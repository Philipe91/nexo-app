import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importante para o Firebase
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- IMPORTS DOS PROVIDERS ---
import 'core/theme/app_theme.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/member_provider.dart';
import 'core/providers/cycle_provider.dart';
import 'core/providers/agreement_provider.dart';
import 'core/providers/preferences_provider.dart';

// --- ARQUIVO GERADO PELO FLUTTERFIRE ---
import 'firebase_options.dart'; 

// --- IMPORTS DAS TELAS ---
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/responsibilities_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart';
import 'screens/members/members_screen.dart';
import 'screens/agreements/agreements_screen.dart';
import 'screens/cycle/cycle_settings_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/family_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INICIALIZAÇÃO DO FIREBASE (O SEGREDO) ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ SUCESSO ABSOLUTO: Firebase Inicializado!");
  } catch (e) {
    print("❌ ERRO NO FIREBASE: $e");
  }
  // ---------------------------------------------

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
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
    // Usando seu Provider original de preferências
    final preferences = Provider.of<PreferencesProvider>(context);

    // Definição das rotas (Router) dentro do build para acessar o contexto
    final _router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const OnboardingScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const AuthScreen()),
        ),
        GoRoute(
          path: '/setup-family',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const FamilySetupScreen()),
        ),
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const HomeScreen()),
        ),
        GoRoute(
          path: '/responsibilities',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const ResponsibilitiesScreen()),
          routes: [
            GoRoute(
              path: 'add',
              pageBuilder: (context, state) => _buildPageWithAnimation(
                context: context, state: state, child: const AddResponsibilityScreen()),
            ),
             GoRoute(
              path: 'edit',
              pageBuilder: (context, state) {
                return _buildPageWithAnimation(
                  context: context, state: state, child: const AddResponsibilityScreen());
              },
            ),
          ],
        ),
        GoRoute(
          path: '/members',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const MembersScreen()),
        ),
        GoRoute(
          path: '/agreements',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const AgreementsScreen()),
        ),
        GoRoute(
          path: '/cycle-settings',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const CycleSettingsScreen()), 
        ),
      ],
    );

    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      
      // Seus Temas Originais
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      routerConfig: _router,
    );
  }

  CustomTransitionPage _buildPageWithAnimation({
    required BuildContext context, 
    required GoRouterState state, 
    required Widget child
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}