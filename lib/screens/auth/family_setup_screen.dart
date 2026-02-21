import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/family_service.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  // Aba selecionada: true = Criar, false = Entrar
  bool _isCreating = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers — Criar família
  final _familyNameCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();

  // Controllers — Entrar na família
  final _codeCtrl = TextEditingController();
  final _memberNameCtrl = TextEditingController();
  String _selectedRole = 'adult'; // 'adult' ou 'child'

  final _familyService = FamilyService();

  @override
  void dispose() {
    _familyNameCtrl.dispose();
    _adminNameCtrl.dispose();
    _codeCtrl.dispose();
    _memberNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    if (_familyNameCtrl.text.trim().isEmpty ||
        _adminNameCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Preencha todos os campos.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _familyService.createFamily(
        familyName: _familyNameCtrl.text.trim(),
        adminName: _adminNameCtrl.text.trim(),
        adminColor: '0xFF4D5BCE',
      );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinFamily() async {
    if (_codeCtrl.text.trim().isEmpty ||
        _memberNameCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Preencha todos os campos.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _familyService.joinFamily(
        inviteCode: _codeCtrl.text.trim(),
        memberName: _memberNameCtrl.text.trim(),
        memberColor: '0xFF4CAF50',
        role: _selectedRole,
      );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Ícone
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.home_work_rounded,
                      size: 56, color: Colors.white),
                ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  'Bem-vindo ao Nexo!',
                  style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ).animate().fade().slideY(begin: 0.3, end: 0, delay: 150.ms),

                const SizedBox(height: 8),

                Text(
                  'Crie sua família ou entre com um código de convite.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ).animate().fade(delay: 250.ms),

                const SizedBox(height: 32),

                // Toggle Criar / Entrar
                _buildToggle(),

                const SizedBox(height: 28),

                // Formulário
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isCreating
                      ? _buildCreateForm()
                      : _buildJoinForm(),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Botão principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_isCreating ? _createFamily : _joinFamily),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4E5AE8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            _isCreating ? 'CRIAR FAMÍLIA' : 'ENTRAR NA FAMÍLIA',
                            style: GoogleFonts.nunito(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                  ),
                ).animate().scale(delay: 500.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleButton('👑 Criar Família', true),
          _toggleButton('🔑 Entrar com código', false),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isCreate) {
    final selected = _isCreating == isCreate;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _isCreating = isCreate;
          _errorMessage = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF4E5AE8) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      key: const ValueKey('create'),
      children: [
        _buildInput(
          label: 'Nome da Família (ex: Família Silva)',
          controller: _familyNameCtrl,
          icon: Icons.people_alt_outlined,
        ),
        const SizedBox(height: 16),
        _buildInput(
          label: 'Seu nome',
          controller: _adminNameCtrl,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Você será o Admin da família',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinForm() {
    return Column(
      key: const ValueKey('join'),
      children: [
        _buildInput(
          label: 'Código de convite (ex: NEXO42)',
          controller: _codeCtrl,
          icon: Icons.vpn_key_outlined,
          caps: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        _buildInput(
          label: 'Seu nome',
          controller: _memberNameCtrl,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        // Seleção de papel
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('  Você é:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                _roleChip('🧑 Adulto', 'adult'),
                const SizedBox(width: 12),
                _roleChip('👦 Filho/a', 'child'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleChip(String label, String role) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF4E5AE8) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextCapitalization caps = TextCapitalization.words,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF2D3561), fontWeight: FontWeight.w500),
        cursorColor: const Color(0xFF4E5AE8),
        textCapitalization: caps,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          prefixIcon: Icon(icon, color: const Color(0xFF4E5AE8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}