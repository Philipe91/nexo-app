import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/providers/member_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 1. Aguarda um tempo mínimo para mostrar a logo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Verifica se existem dados salvos no dispositivo
    final prefs = await SharedPreferences.getInstance();
    final hasMembers = prefs.containsKey('members_data') && 
                       (prefs.getString('members_data') != "[]");

    // 3. Verifica também se o Provider já carregou
    final memberProvider = context.read<MemberProvider>();
    
    // 4. Decide para onde ir
    if (hasMembers || memberProvider.members.isNotEmpty) {
      context.go('/'); // Vai para Home
    } else {
      context.go('/onboarding'); // Usuário novo
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