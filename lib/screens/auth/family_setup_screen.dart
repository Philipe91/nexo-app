import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text("Configuração Inicial")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work_rounded, size: 80, color: Colors.indigo),
            const SizedBox(height: 24),
            Text(
              "Como sua família se chama?",
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Isso aparecerá no topo do aplicativo para todos os membros.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _familyNameController,
              decoration: InputDecoration(
                labelText: "Nome da Família (ex: Família Silva)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _finishSetup,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("TUDO PRONTO"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}