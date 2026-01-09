import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Imports das telas
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/create_family_screen.dart';
import 'screens/onboarding/add_members_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart';
import 'screens/responsibilities/responsibilities_screen.dart';
import 'screens/members/members_screen.dart';
import 'screens/checkin/checkin_screen.dart';
import 'screens/agreements/agreements_screen.dart';
import 'screens/settings/settings_screen.dart'; // <--- O Import que faltava

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. Rota Inicial (Onboarding)
    GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
    
    // 2. Criar Família
    GoRoute(path: '/create-family', builder: (context, state) => const CreateFamilyScreen()),
    
    // 3. Adicionar Membros
    GoRoute(
      path: '/add-members',
      builder: (context, state) {
        final name = state.extra as String? ?? 'Sua Família';
        return AddMembersScreen(familyName: name);
      },
    ),

    // 4. Home (Principal)
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // 5. Nova Responsabilidade
    GoRoute(path: '/responsibilities/add', builder: (context, state) => const AddResponsibilityScreen()),

    // 6. Lista de Responsabilidades (Ver Todas)
    GoRoute(path: '/responsibilities', builder: (context, state) => const ResponsibilitiesScreen()),

    // 7. Membros
    GoRoute(path: '/members', builder: (context, state) => const MembersScreen()),

    // 8. Check-in
    GoRoute(path: '/checkin', builder: (context, state) => const CheckInScreen()),

    // 9. Acordos
    GoRoute(path: '/agreements', builder: (context, state) => const AgreementsScreen()),

    // 10. Configurações (A rota que estava faltando!)
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);