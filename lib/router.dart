import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTS DAS TELAS ---
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/family_setup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/responsibilities_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart';
import 'screens/members/members_screen.dart';
import 'screens/agreements/agreements_screen.dart';
import 'screens/cycle/cycle_settings_screen.dart';
import 'screens/kid_mode/kid_mode_screen.dart'; 
import 'screens/shopping/shopping_list_screen.dart'; // <--- Import Novo
import 'screens/shopping/meal_planner_screen.dart'; // <--- Import Novo
import 'screens/checkin/checkin_screen.dart'; // <--- Import Novo

// Configuração Centralizada de Rotas
GoRouter createAppRouter({String initialLocation = '/splash'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // 0. SPLASH (Inicialização)
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

      // 3. CONFIGURAÇÃO DA FAMÍLIA
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
              // TODO: Passar o objeto Task via state.extra se necessário para edição
              // final task = state.extra as Task?;
              return _buildPageWithAnimation(
                context: context, state: state, child: const AddResponsibilityScreen());
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
      
      // 8. CICLO (CORAÇÃO)
      GoRoute(
        path: '/cycle-settings',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const CycleSettingsScreen()), 
      ),

      // 9. MODO CRIANÇA (GAMIFICAÇÃO)
      GoRoute(
        path: '/kid-mode',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const KidModeScreen()), 
      ),

      // 10. LISTA DE COMPRAS
      GoRoute(
        path: '/shopping',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const ShoppingListScreen()), 
      ),

      // 11. PLANEJAMENTO DE REFEIÇÕES
      GoRoute(
        path: '/meals',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const MealPlannerScreen()), 
      ),

      // 12. CHECK-IN SEMANAL
      GoRoute(
        path: '/checkin',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const CheckInScreen()), 
      ),
    ],
  );
}

// --- ANIMAÇÃO PADRÃO ---
CustomTransitionPage _buildPageWithAnimation({
  required BuildContext context, 
  required GoRouterState state, 
  required Widget child
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide da direita para a esquerda + Fade
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