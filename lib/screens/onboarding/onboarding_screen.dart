import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pegamos as cores e estilos do tema definido no main.dart
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(), // Empurra o conteúdo para o centro

              // Ícone ou Logo
              Icon(
                Icons.home_work_rounded, 
                size: 80, 
                color: theme.colorScheme.primary
              ),
              
              const SizedBox(height: 32),

              // Título de Impacto
              Text(
                'Bem-vindo ao NEXO',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtítulo explicativo
              Text(
                'Equilibre a carga mental, organize as responsabilidades e traga harmonia para sua casa.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(), // Empurra o botão para o final

              // Botão Principal
              FilledButton(
                onPressed: () {
                  // Navega para a tela de criar família
                  context.push('/create-family'); 
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Começar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 24), // Margem final
            ],
          ),
        ),
      ),
    );
  }
}