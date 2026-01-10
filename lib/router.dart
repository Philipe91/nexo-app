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
import 'screens/kids/kid_mode_screen.dart'; // <--- Import Novo
import '../models/task_model.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(
        path: '/create-family',
        builder: (context, state) => const CreateFamilyScreen()),
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
    GoRoute(
        path: '/responsibilities',
        builder: (context, state) => const ResponsibilitiesScreen()),
    GoRoute(
        path: '/members', builder: (context, state) => const MembersScreen()),
    GoRoute(
        path: '/checkin', builder: (context, state) => const CheckInScreen()),
    GoRoute(
        path: '/agreements',
        builder: (context, state) => const AgreementsScreen()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsScreen()),

    GoRoute(
        path: '/planning',
        builder: (context, state) => const WeeklyPlanningScreen()),
    // --- NOVA ROTA ---
    GoRoute(
        path: '/kid-mode', builder: (context, state) => const KidModeScreen()),
  ],
);
