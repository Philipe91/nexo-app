import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- PROVIDERS ---
import 'core/theme/app_theme.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/member_provider.dart';
import 'core/providers/cycle_provider.dart';
import 'core/providers/agreement_provider.dart';
import 'core/providers/preferences_provider.dart';
import 'core/providers/checkin_provider.dart';

// --- TELAS ---
import 'screens/splash_screen.dart'; // <--- O IMPORT QUE FALTAVA
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/family_setup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/responsibilities_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart';
import 'screens/members/members_screen.dart';
import 'screens/agreements/agreements_screen.dart';
import 'screens/cycle/cycle_settings_screen.dart';
import 'screens/planning/weekly_planning_screen.dart'; 
import 'screens/kid_mode/kid_mode_screen.dart';
import 'screens/checkin/checkin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => CheckInProvider()),
      ],
      // CORREÇÃO: Começa sempre pelo Splash para ele decidir o destino
      child: const NexoApp(initialLocation: '/splash'),
    ),
  );
}

class NexoApp extends StatelessWidget {
  final String initialLocation;

  const NexoApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesProvider>(context);

    final _router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        // 0. SPLASH (CÉREBRO) - Restaurado
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // 1. INTRODUÇÃO
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const OnboardingScreen()),
        ),

        // 2. LOGIN / CADASTRO
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const AuthScreen()),
        ),

        // 3. SETUP DA FAMÍLIA
        GoRoute(
          path: '/setup-family',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const FamilySetupScreen()),
        ),

        // 4. HOME (DASHBOARD)
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const HomeScreen()),
        ),

        // 5. RESPONSABILIDADES
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
                final task = state.extra; 
                // Assumindo que AddResponsibilityScreen trata null se necessário
                return _buildPageWithAnimation(
                  context: context, state: state, child: AddResponsibilityScreen(taskToEdit: task as dynamic)); 
              },
            ),
          ],
        ),

        // 6. MEMBROS
        GoRoute(
          path: '/members',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const MembersScreen()),
        ),

        // 7. ACORDOS
        GoRoute(
          path: '/agreements',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const AgreementsScreen()),
        ),
        
        // 8. CICLO
        GoRoute(
          path: '/cycle-settings',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const CycleSettingsScreen()), 
        ),

        // 9. PLANEJAMENTO SEMANAL
        GoRoute(
          path: '/planning',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const WeeklyPlanningScreen()),
        ),

        // 10. MODO CRIANÇA
        GoRoute(
          path: '/kid-mode',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const KidModeScreen()),
        ),

        // 11. CHECK-IN SEMANAL
        GoRoute(
          path: '/checkin',
          pageBuilder: (context, state) => _buildPageWithAnimation(
            context: context, state: state, child: const CheckInScreen()),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
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