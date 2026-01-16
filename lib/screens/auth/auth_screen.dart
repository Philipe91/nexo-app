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

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // --- ÁREA DA LOGO ---
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1), 
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.grid_view_rounded, 
                    size: 50,
                    color: primaryColor,
                  ),
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 32),

              // Título
              Text(
                _isLogin ? "Bem-vindo ao NEXO" : "Crie sua conta",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ).animate().fade().slideY(begin: -0.5, end: 0, delay: 200.ms),
              
              const SizedBox(height: 8),
              
              Text(
                _isLogin 
                  ? "Sua carga mental organizada." 
                  : "Comece a dividir as tarefas hoje.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ).animate().fade(delay: 300.ms),

              const SizedBox(height: 48),

              // Campos
              if (!_isLogin) ...[
                _buildTextField(label: "Seu Nome", icon: Icons.person_outline, controller: _nameController)
                .animate().fade().slideX(begin: -0.2, end: 0),
                const SizedBox(height: 16),
              ],
              
              _buildTextField(label: "E-mail", icon: Icons.email_outlined, controller: _emailController)
              .animate().fade(delay: 100.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              _buildTextField(label: "Senha", icon: Icons.lock_outline, controller: _passController, isPassword: true)
              .animate().fade(delay: 200.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 32),

              // Botão Principal
              ElevatedButton(
                onPressed: _submitAuth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(
                  _isLogin ? "ENTRAR" : "CRIAR CONTA",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ).animate().scale(delay: 400.ms),

              const SizedBox(height: 24),

              // Alternar Login/Cadastro
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: RichText(
                  text: TextSpan(
                    text: _isLogin ? "Não tem conta? " : "Já tem conta? ",
                    style: TextStyle(color: Colors.grey[600], fontFamily: GoogleFonts.inter().fontFamily),
                    children: [
                      TextSpan(
                        text: _isLogin ? "Cadastre-se" : "Faça Login",
                        style: TextStyle(
                          color: primaryColor, 
                          fontWeight: FontWeight.bold
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
    );
  }

  Widget _buildTextField({
    required String label, 
    required IconData icon, 
    required TextEditingController controller,
    bool isPassword = false
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}