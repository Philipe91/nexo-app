import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/nexo_loading.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Alternar entre Login e Cadastro
  bool _isLoading = false; 
  
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController(); 

  void _submitAuth() async {
    setState(() {
      _isLoading = true; 
    });

    // Simula tempo de processamento
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.go('/setup-family'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const NexoLoading(message: "Entrando na sua casa...");
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
                    color: primaryColor.withOpacity(0.1), // Fundo suave
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.grid_view_rounded, // <--- SE TIVER UMA IMAGEM, TROQUE AQUI POR Image.asset('assets/logo.png')
                    size: 50,
                    color: primaryColor,
                  ),
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut), // Efeito elástico ao aparecer

              const SizedBox(height: 32),
              // -------------------

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

              // Campos (Inputs)
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