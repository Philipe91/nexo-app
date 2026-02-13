import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- O CARA DO LOGIN
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- O CARA DO BANCO DE DADOS
import '../../core/widgets/nexo_loading.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; 
  bool _isLoading = false; 
  
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController(); 

  // --- FUNÇÃO REAL DE AUTENTICAÇÃO ---
  void _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Preencha email e senha.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- LOGICA DE LOGIN ---
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, 
          password: password
        );
      } else {
        // --- LOGICA DE CRIAR CONTA (SIGN UP) ---
        if (name.isEmpty) {
          _showError("Por favor, diga seu nome.");
          setState(() => _isLoading = false);
          return;
        }

        // 1. Cria o usuário no Authentication (Email/Senha)
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );

        // 2. Grava os dados na pasta 'users' do Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'currentFamilyId': null, // Ainda sem família
        });
      }

      // Se não deu erro, navega!
      if (mounted) {
        context.go('/setup-family'); 
      }

    } on FirebaseAuthException catch (e) {
      // Tratamento de erros comuns
      String msg = "Ocorreu um erro.";
      if (e.code == 'weak-password') msg = "A senha é muito fraca.";
      if (e.code == 'email-already-in-use') msg = "Este e-mail já está cadastrado.";
      if (e.code == 'invalid-email') msg = "E-mail inválido.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password') msg = "Email ou senha incorretos."; // Segurança
      
      _showError(msg);
    } catch (e) {
      _showError("Erro inesperado: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const NexoLoading(message: "Conectando com o servidor...");
    }

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // --- LOGO ANIMADA ---
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), 
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                        ]
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded, 
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 48),

                  // Títulos
                  Text(
                    _isLogin ? "Bem-vindo" : "Nova Conta",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ).animate().fade().slideY(begin: 0.3, end: 0, delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _isLogin 
                      ? "Faça login para continuar" 
                      : "Junte-se ao NEXO hoje",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70),
                  ).animate().fade(delay: 300.ms),

                  const SizedBox(height: 48),

                  // Campos
                  if (!_isLogin) ...[
                    _buildMoonInput(label: "Seu Nome", icon: Icons.person_outline, controller: _nameController)
                    .animate().fade().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                  ],
                  
                  _buildMoonInput(label: "E-mail", icon: Icons.email_outlined, controller: _emailController)
                  .animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  _buildMoonInput(label: "Senha", icon: Icons.lock_outline, controller: _passController, isPassword: true)
                  .animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  // Botão Branco (Estilo Moon Heart)
                  ElevatedButton(
                    onPressed: _submitAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: Text(
                      _isLogin ? "ENTRAR" : "CRIAR CONTA",
                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ).animate().scale(delay: 400.ms),

                  const SizedBox(height: 24),

                  // Alternar Login/Cadastro
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? "Ainda não tem conta? " : "Já possui conta? ",
                        style: GoogleFonts.nunito(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: _isLogin ? "Cadastre-se" : "Entrar",
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoonInput({
    required String label, 
    required IconData icon, 
    required TextEditingController controller,
    bool isPassword = false
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // Menos opacidade para mostrar o blur
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)), // Borda sutil
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              filled: false, // Importante para o efeito glass funcionar (não usar o branco do tema)
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: Icon(icon, color: Colors.white70),
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