import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Imports das telas
import 'screens/splash_screen.dart'; // <--- Import Novo
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/create_family_screen.dart';
import 'screens/onboarding/add_members_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart';
import 'screens/responsibilities/responsibilities_screen.dart';
import 'screens/members/members_screen.dart';
import 'screens/checkin/checkin_screen.dart';
import 'screens/agreements/agreements_screen.dart';
import 'screens/settings/settings_screen.dart';
import '../models/task_model.dart'; // Ajuste o caminho se necessário (ex: 'models/task_model.dart')

final router = GoRouter(
  initialLocation: '/', // Começa sempre pela raiz
  routes: [
    // 1. Rota Raiz agora é a SPLASH (O porteiro)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // 2. Rota de Onboarding agora tem endereço próprio
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    
    // --- Resto das rotas continua igual ---
    GoRoute(path: '/create-family', builder: (context, state) => const CreateFamilyScreen()),
    
    GoRoute(
      path: '/add-members',
      builder: (context, state) {
        final name = state.extra as String? ?? 'Sua Família';
        return AddMembersScreen(familyName: name);
      },
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/responsibilities/add',
      builder: (context, state) {
        final taskToEdit = state.extra as Task?;
        return AddResponsibilityScreen(taskToEdit: taskToEdit);
      },
    ),

    GoRoute(path: '/responsibilities', builder: (context, state) => const ResponsibilitiesScreen()),
    GoRoute(path: '/members', builder: (context, state) => const MembersScreen()),
    GoRoute(path: '/checkin', builder: (context, state) => const CheckInScreen()),
    GoRoute(path: '/agreements', builder: (context, state) => const AgreementsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);