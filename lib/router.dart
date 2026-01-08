// --- SEÇÃO DE IMPORTS ---
// Importa o pacote oficial do GoRouter, necessário para o sistema de rotas funcionar.
import 'package:go_router/go_router.dart';

// Importa as telas que criamos para que o roteador saiba o que mostrar.
import 'screens/onboarding/create_family_screen.dart'; // Import que você já tinha adicionado
import 'screens/onboarding/add_members_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/responsibilities/responsibilities_screen.dart';
import 'screens/responsibilities/add_responsibility_screen.dart'; 

// Definimos a variável 'router' (pública) que será usada no main.dart.
// Ela guarda toda a configuração de navegação do app.
final router = GoRouter(
  
  // initialLocation: Define qual tela abre assim que o app inicia.
  initialLocation: '/',

  // routes: É uma lista [] onde definimos cada caminho possível dentro do app.
  routes: [
    
    // Rota Raiz (Splash ou Onboarding)
    GoRoute(
      path: '/', // O caminho na URL
      builder: (context, state) => const OnboardingScreen(),
    ),

// Rota de Adicionar Membros
    GoRoute(
      path: '/add-members',
      builder: (context, state) {
        // Pega o objeto (nome) passado pela tela anterior
        final name = state.extra as String? ?? 'Sua Família';
        return AddMembersScreen(familyName: name);
      },
    ),




    // --- NOVA ROTA ADICIONADA AQUI ---
    // Rota para criar a família (próximo passo do onboarding)
    GoRoute(
      path: '/create-family',
      builder: (context, state) => const CreateFamilyScreen(),
    ),
    // ---------------------------------

    // Rota da Home Principal
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Rota da Lista de Responsabilidades
    GoRoute(
      path: '/responsibilities',
      builder: (context, state) => const ResponsibilitiesScreen(),
    ),

    // Rota para a tela de Adicionar Nova Responsabilidade
    GoRoute(
      path: '/responsibilities/add', 
      builder: (context, state) => const AddResponsibilityScreen(),
    ),
    
  ], // Fim da lista de rotas
); // Fim da configuração do GoRouter