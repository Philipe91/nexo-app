import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Imports das telas
import 'screens/splash_screen.dart';
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
import 'screens/planning/weekly_planning_screen.dart';
import 'screens/kids/kid_mode_screen.dart';
import 'screens/cycle/cycle_settings_screen.dart'; // <--- Import Novo (Bio-Ritmo)
import '../models/task_model.dart';

final router = GoRouter(
  initialLocation: '/', 
  routes: [
    // 1. Rota Raiz agora é a SPLASH
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // 2. Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/create-family', builder: (context, state) => const CreateFamilyScreen()),
    GoRoute(
      path: '/add-members',
      builder: (context, state) {
        final name = state.extra as String? ?? 'Sua Família';
        return AddMembersScreen(familyName: name);
      },
    ),

    // 3. Home e Funcionalidades Principais
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Responsabilidades
    GoRoute(
      path: '/responsibilities/add',
      builder: (context, state) {
        final taskToEdit = state.extra as Task?;
        return AddResponsibilityScreen(taskToEdit: taskToEdit);
      },
    ),
    GoRoute(path: '/responsibilities', builder: (context, state) => const ResponsibilitiesScreen()),

    // Membros
    GoRoute(path: '/members', builder: (context, state) => const MembersScreen()),

    // Check-in
    GoRoute(path: '/checkin', builder: (context, state) => const CheckInScreen()),

    // Acordos
    GoRoute(path: '/agreements', builder: (context, state) => const AgreementsScreen()),

    // Configurações
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    
    // Planejamento Semanal
    GoRoute(path: '/planning', builder: (context, state) => const WeeklyPlanningScreen()),
    
    // Modo Filho (Gamificação)
    GoRoute(path: '/kid-mode', builder: (context, state) => const KidModeScreen()),
    
    // --- NOVA ROTA: Configuração do Bio-Ritmo ---
    GoRoute(path: '/cycle-settings', builder: (context, state) => const CycleSettingsScreen()),
  ],
);