import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../providers/preferences_provider.dart'; // <--- Import

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;
    final prefs = context.watch<PreferencesProvider>(); // <--- Escuta Preferências

    final isDark = prefs.isDarkMode;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Efeito de Blur (Adaptado para Dark Mode)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              // No Dark Mode, o fundo do drawer fica escuro e translúcido
              color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABEÇALHO ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        prefs.familyName, // <--- Nome Real da Família
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "Gestão inteligente do lar",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade400 : Colors.grey
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // --- MEMBROS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text("Membros", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ),
                
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...members.map((m) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(m.name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          context.pop();
                          context.push('/members');
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      )
                    ],
                  ),
                ),

                const Divider(),

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
                
                // --- SWITCH MODO ESCURO FUNCIONAL ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Modo Escuro")),
                        Switch(
                          value: isDark,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            // Troca o tema globalmente
                            context.read<PreferencesProvider>().toggleTheme(val);
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