import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _toast('Preencha e-mail e senha.');
      return;
    }
    if (!_isLogin && name.isEmpty) {
      _toast('Diga seu nome para começar.');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      } else {
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'currentFamilyId': null,
        });
      }
      if (mounted) context.go('/setup-family');
    } on FirebaseAuthException catch (e) {
      _toast(_mapError(e.code));
    } catch (_) {
      _toast('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Não foi possível autenticar agora.';
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;

    return Scaffold(
      body: AmbientBackground(
        intensity: 0.9,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NexoSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: NexoSpace.xxl),
                    _Brand(dark: dark),
                    const SizedBox(height: NexoSpace.xxxl),
                    Text(
                      _isLogin ? 'Bem-vinda de volta' : 'Crie sua conta',
                      style: AppTheme.display(size: 32, weight: FontWeight.w800, color: fg),
                    ),
                    const SizedBox(height: NexoSpace.sm),
                    Text(
                      _isLogin
                          ? 'Entre para continuar onde parou.'
                          : 'Comece a equilibrar a casa em minutos.',
                      style: TextStyle(fontSize: NexoText.base, color: fgMuted, height: 1.5),
                    ),
                    const SizedBox(height: NexoSpace.xxl),

                    if (!_isLogin) ...[
                      AppTextField(
                        label: 'Seu nome',
                        controller: _nameCtrl,
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: NexoSpace.lg),
                    ],
                    AppTextField(
                      label: 'E-mail',
                      controller: _emailCtrl,
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: NexoSpace.lg),
                    AppTextField(
                      label: 'Senha',
                      controller: _passCtrl,
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      autofillHints: [_isLogin ? AutofillHints.password : AutofillHints.newPassword],
                      helper: _isLogin ? null : 'Mínimo 6 caracteres.',
                    ),

                    const SizedBox(height: NexoSpace.xl),
                    AppButton(
                      label: _isLogin ? 'Entrar' : 'Criar conta',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: NexoSpace.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? 'Ainda não tem conta? ' : 'Já possui conta? ',
                          style: TextStyle(color: fgMuted, fontSize: NexoText.sm),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          style: TextButton.styleFrom(
                            foregroundColor: accent,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          ),
                          child: Text(
                            _isLogin ? 'Cadastre-se' : 'Entrar',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: NexoText.sm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: NexoColors.indigo,
            borderRadius: BorderRadius.circular(11),
            boxShadow: NexoElevation.glow(NexoColors.indigo, opacity: 0.30),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          'NEXO',
          style: AppTheme.display(
            size: 28,
            weight: FontWeight.w800,
            color: dark ? NexoColors.darkFg : NexoColors.lightFg,
          ),
        ),
      ],
    );
  }
}
