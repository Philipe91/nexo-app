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
import 'screens/kid_mode/rewards_screen.dart'; // <--- Import Novo
import 'screens/shopping/shopping_list_screen.dart'; // <--- Import Novo
import 'package:nexo/screens/stats/statistics_screen.dart'; 
import 'screens/ai/nexo_assistant_screen.dart';
import 'screens/stats/mental_load_history_screen.dart'; // <--- Import Adicionado // <--- Import Novo
import 'screens/shopping/meal_planner_screen.dart'; // <--- Import Novo
import 'screens/checkin/checkin_screen.dart'; // <--- Import Novo
import 'screens/scaffold_with_navbar.dart'; // <--- Import Novo para Navbar
import 'screens/planning/weekly_planning_screen.dart'; // <--- Import Novo
import 'screens/settings/settings_screen.dart'; // <--- Import Novo
import 'screens/settings/manage_rewards_screen.dart'; 
import 'screens/bank/bank_screen.dart'; // <--- Import Novo
import 'screens/bank/bank_manager_screen.dart'; // <--- Import Novo

// Configuração Centralizada de Rotas
// Configuração Centralizada de Rotas
GoRouter createAppRouter({String initialLocation = '/splash'}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final sectionNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      // 0. SPLASH (Inicialização)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/stats',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const StatisticsScreen()),
      ),
      GoRoute(
        path: '/assistant',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const NexoAssistantScreen()),
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

      // ROTAS COM BARRA DE NAVEGAÇÃO (SHELL)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // BRANCH 1: HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => _buildPageWithAnimation(
                  context: context, state: state, child: const HomeScreen()),
              ),
            ],
          ),

          // BRANCH 2: RESPONSABILIDADES
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/responsibilities',
                pageBuilder: (context, state) => _buildPageWithAnimation(
                  context: context, state: state, child: const ResponsibilitiesScreen()),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: rootNavigatorKey, // Esconde a navbar
                    pageBuilder: (context, state) => _buildPageWithAnimation(
                      context: context, state: state, child: const AddResponsibilityScreen()),
                  ),
                   GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootNavigatorKey, // Esconde a navbar
                    pageBuilder: (context, state) {
                      return _buildPageWithAnimation(
                        context: context, state: state, child: const AddResponsibilityScreen());
                    },
                  ),
                ],
              ),
            ],
          ),

          // BRANCH 3: SHOPPING
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shopping',
                pageBuilder: (context, state) => _buildPageWithAnimation(
                  context: context, state: state, child: const ShoppingListScreen()), 
              ),
            ],
          ),

          // BRANCH 4: MEMBROS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/members',
                pageBuilder: (context, state) => _buildPageWithAnimation(
                  context: context, state: state, child: const MembersScreen()),
              ),
            ],
          ),
        ],
      ),

      // OUTRAS ROTAS (Sem barra de navegação)
      
      // 7. ACORDOS
      GoRoute(
        path: '/agreements',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const AgreementsScreen()),
      ),
      
      // 8. CICLO (CORAÇÃO)
      GoRoute(
        path: '/cycle-settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const CycleSettingsScreen()), 
      ),

      // 9. MODO CRIANÇA (GAMIFICAÇÃO)
      GoRoute(
        path: '/kid-mode',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const KidModeScreen()), 
      ),

      // 10. LOJA DE RECOMPENSAS
      GoRoute(
        path: '/rewards/:kidId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final kidId = state.pathParameters['kidId']!;
          return _buildPageWithAnimation(
            context: context, state: state, child: RewardsScreen(kidId: kidId)); 
        },
      ),

      // 10. LISTA DE COMPRAS - MOVED TO SHELL BUT KEEPING HERE AS FALLBACK IF NEEDED OR REMOVING
      // (Já está no Shell)

      // 11. PLANEJAMENTO DE REFEIÇÕES
      GoRoute(
        path: '/meals',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const MealPlannerScreen()), 
      ),

      // 13. PLANEJAMENTO SEMANAL (Faltava esta rota!)
      GoRoute(
        path: '/planning',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const WeeklyPlanningScreen()), 
      ),

      // 12. CHECK-IN SEMANAL
      GoRoute(
        path: '/mental-load-history',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const MentalLoadHistoryScreen()),
      ),
      GoRoute(
        path: '/checkin',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const CheckInScreen()), 
      ),

      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const SettingsScreen()), 
      ),

      // 15. GERENCIAR RECOMPENSAS
      GoRoute(
        path: '/manage-rewards',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const ManageRewardsScreen()), 
      ),

      // 16. BANCO
      GoRoute(
        path: '/bank/:kidId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final kidId = state.pathParameters['kidId']!;
          return _buildPageWithAnimation(
            context: context, state: state, child: BankScreen(kidId: kidId)); 
        },
      ),

      // 17. GERENCIAR BANCO
      GoRoute(
        path: '/manage-bank',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context: context, state: state, child: const BankManagerScreen()), 
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