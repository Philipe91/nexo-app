import 'dart:ui'; // Necessário para o efeito de blur
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glass_card.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Permite que o fundo passe por trás da barra superior
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'NEXO', 
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined), 
            color: Colors.black87,
            onPressed: () {}
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- 1. FUNDO COM FORMAS SUAVES (AMBIENT LIGHT) ---
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.5),
              ),
            ).blur(80), // Efeito de borrar
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.shade100.withOpacity(0.5),
              ),
            ).blur(60),
          ),
          
          // --- 2. CONTEÚDO PRINCIPAL ---
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                
                // Card de Status (Vidro Branco)
                GlassCard(
                  opacity: 0.6,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: Colors.orange.shade300),
                            const SizedBox(width: 8),
                            Text(
                              'Bom dia, Família!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                 color: Colors.grey.shade700
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Carga Mental',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Equilibrada',
                          style: TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: 0.7,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Acesso Rápido", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),

                // Botões de Ação
                Row(
                  children: [
                    // --- BOTÃO NOVA TAREFA ---
                    Expanded(
                      child: GlassCard(
                        // AQUI ESTÁ A LIGAÇÃO CORRETA:
                        onTap: () => context.push('/responsibilities/add'), 
                        
                        color: theme.colorScheme.primary, // Azul
                        opacity: 0.9, 
                        child: const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.add_task, color: Colors.white, size: 32),
                              SizedBox(height: 12),
                              Text(
                                "Nova Tarefa", 
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // --- BOTÃO MEMBROS ---
                    Expanded(
                      child: GlassCard(
                        onTap: () {
                           // Futuro: context.push('/members');
                        },
                        color: Colors.white,
                        opacity: 0.7,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, color: theme.colorScheme.primary, size: 32),
                              const SizedBox(height: 12),
                              Text(
                                "Membros", 
                                style: TextStyle(
                                  color: theme.colorScheme.primary, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extensão necessária para o efeito de blur nas formas do fundo
extension BlurEffect on Container {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}