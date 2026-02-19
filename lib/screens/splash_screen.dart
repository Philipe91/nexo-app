import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart'; // <--- AuthProvider
// import 'package:shared_preferences/shared_preferences.dart'; // Removido
// import '../core/providers/member_provider.dart'; // Removido logicamente

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia a verificação assim que a tela monta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    // 1. Aguarda um tempo mínimo para mostrar a logo (UX)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // Pequeno delay para garantir que o AuthProvider teve tempo de inicializar
    // (Caso o Firebase demore um pouco para responder o estado inicial)
    if (authProvider.status == AuthGateStatus.initializing) {
      // Loop simples de espera (com timeout)
      int retries = 0;
      while (authProvider.status == AuthGateStatus.initializing && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries++;
      }
    }

    // 2. Decide para onde ir com base no status do AuthProvider
    if (authProvider.status == AuthGateStatus.authenticatedInFamily) {
      context.go('/'); // Home
    } else if (authProvider.status == AuthGateStatus.authenticatedNoFamily) {
      context.go('/setup-family'); // Completar cadastro
    } else {
      context.go('/onboarding'); // Intro / Login
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Icon(
                    Icons.home_work_rounded, 
                    size: 80, 
                    color: Colors.white
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "NEXO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}