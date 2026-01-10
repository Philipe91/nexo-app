import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;

    return Drawer(
      backgroundColor: Colors.transparent, // Transparente para o Glassmorfismo
      child: Stack(
        children: [
          // Efeito de Blur no fundo do Drawer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABEÇALHO DO DRAWER ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.home_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Família NEXO",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "Gestão inteligente do lar",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // --- LISTA DE MEMBROS (RESUMO) ---
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text("Membros",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600)),
                ),

                // Lista horizontal pequena dentro do drawer
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...members.map((m) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(m.name[0],
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )),
                      // Botão de Adicionar
                      IconButton(
                        onPressed: () {
                          context.pop(); // Fecha drawer
                          context.push('/members');
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: "Gerenciar Membros",
                      )
                    ],
                  ),
                ),

                const Divider(),

                // --- MENUS DE NAVEGAÇÃO ---
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text("Configurações"),
                  onTap: () {
                    context.pop();
                    context.push('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text("Gerenciar Membros"),
                  onTap: () {
                    context.pop();
                    context.push('/members');
                  },
                ),

                const Spacer(),

                // --- RODAPÉ (MODO DARK FUTURO) ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode_outlined),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Modo Escuro")),
                        Switch(
                          value: false, // Placeholder
                          onChanged: (val) {
                            // Implementaremos no futuro
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Em breve!")));
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
