import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Imports das telas
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/create_family_screen.dart';
import 'screens/onboarding/add_members_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart';
import 'screens/members/members_screen.dart';
import 'screens/checkin/checkin_screen.dart';
import 'screens/agreements/agreements_screen.dart'; // <--- Import Novo

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Rota Inicial (Onboarding)
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    
    // Rota Criar Família
    GoRoute(
      path: '/create-family',
      builder: (context, state) => const CreateFamilyScreen(),
    ),
    
    // Rota Adicionar Membros (No cadastro)
    GoRoute(
      path: '/add-members',
      builder: (context, state) {
        final name = state.extra as String? ?? 'Sua Família';
        return AddMembersScreen(familyName: name);
      },
    ),

    // Rota Home (Principal)
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Rota Nova Responsabilidade
    GoRoute(
      path: '/responsibilities/add',
      builder: (context, state) => const AddResponsibilityScreen(),
    ),

    // Rota Membros (Gerenciamento)
    GoRoute(
      path: '/members',
      builder: (context, state) => const MembersScreen(),
    ),

    // Rota Check-in
    GoRoute(
      path: '/checkin',
      builder: (context, state) => const CheckInScreen(),
    ),

    // --- NOVA ROTA: ACORDOS ---
    GoRoute(
      path: '/agreements',
      builder: (context, state) => const AgreementsScreen(),
    ),
  ],
);