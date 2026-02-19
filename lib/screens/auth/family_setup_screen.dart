import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/providers/member_provider.dart'; 

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final _familyNameController = TextEditingController();

  void _finishSetup() {
    if (_familyNameController.text.isNotEmpty) {
      // 1. Salva o nome da família nas preferências
      context.read<PreferencesProvider>().updateFamilyName(_familyNameController.text);
      
      // 2. CRIA O PRIMEIRO MEMBRO (VOCÊ)
      // Isso evita o loop infinito, pois agora o app sabe que existe um membro
      context.read<MemberProvider>().addMember(
        "Eu (Admin)", 
        "0xFF4D5BCE" // Azul padrão
      );
      
      // 3. Vai para a Home
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)], // Moon Heart Gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- ÍCONE CENTRAL ---
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                  child: const Icon(Icons.home_work_rounded, size: 60, color: Colors.white),
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

                const SizedBox(height: 48),

                Text(
                  "Como sua família se chama?",
                  style: GoogleFonts.nunito(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800,
                    color: Colors.white
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade().slideY(begin: 0.3, end: 0, delay: 200.ms),

                const SizedBox(height: 12),

                Text(
                  "Isso aparecerá no topo do aplicativo para todos os membros.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ).animate().fade(delay: 300.ms),

                const SizedBox(height: 48),
                
                // --- INPUT GLASS ---
                _buildMoonInput(
                  label: "Nome da Família (ex: Família Silva)",
                  controller: _familyNameController
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const Spacer(),
                
                // --- BOTÃO DE CONFIRMAÇÃO ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishSetup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: Text(
                      "TUDO PRONTO",
                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().scale(delay: 600.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoonInput({
    required String label, 
    required TextEditingController controller,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)), 
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              filled: false, 
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.people_alt_outlined, color: Colors.white70),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
        ),
      ),
    );
  }
}