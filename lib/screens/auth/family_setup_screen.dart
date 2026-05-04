import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/family_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

enum _Mode { create, join }

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  _Mode _mode = _Mode.create;
  bool _loading = false;
  String? _errorText;

  final _familyNameCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _memberNameCtrl = TextEditingController();
  String _role = 'adult';

  final _service = FamilyService();

  @override
  void dispose() {
    _familyNameCtrl.dispose();
    _adminNameCtrl.dispose();
    _codeCtrl.dispose();
    _memberNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);
    try {
      setState(() => _loading = true);
      if (_mode == _Mode.create) {
        if (_familyNameCtrl.text.trim().isEmpty || _adminNameCtrl.text.trim().isEmpty) {
          setState(() => _errorText = 'Preencha todos os campos.');
          return;
        }
        await _service.createFamily(
          familyName: _familyNameCtrl.text.trim(),
          adminName: _adminNameCtrl.text.trim(),
          adminColor: '0xFF5E6AD2',
        );
      } else {
        if (_codeCtrl.text.trim().isEmpty || _memberNameCtrl.text.trim().isEmpty) {
          setState(() => _errorText = 'Preencha todos os campos.');
          return;
        }
        await _service.joinFamily(
          inviteCode: _codeCtrl.text.trim(),
          memberName: _memberNameCtrl.text.trim(),
          memberColor: '0xFF10B981',
          role: _role,
        );
      }
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _errorText = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Scaffold(
      body: AmbientBackground(
        intensity: 0.8,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NexoSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: NexoSpace.lg),
                    Text(
                      'Sua família\nno NEXO',
                      style: AppTheme.display(size: 32, weight: FontWeight.w800, color: fg),
                    ),
                    const SizedBox(height: NexoSpace.sm),
                    Text(
                      _mode == _Mode.create
                          ? 'Crie a base e convide quem mora com você.'
                          : 'Use o código que receberam para entrar na família.',
                      style: TextStyle(fontSize: NexoText.base, color: fgMuted, height: 1.5),
                    ),
                    const SizedBox(height: NexoSpace.xl),
                    _ModeSwitch(
                      value: _mode,
                      onChanged: (m) => setState(() {
                        _mode = m;
                        _errorText = null;
                      }),
                    ),
                    const SizedBox(height: NexoSpace.xl),
                    AnimatedSwitcher(
                      duration: NexoMotion.normal,
                      switchInCurve: NexoMotion.standard,
                      transitionBuilder: (c, anim) =>
                          FadeTransition(opacity: anim, child: c),
                      child: _mode == _Mode.create
                          ? _CreateForm(
                              key: const ValueKey('create'),
                              familyName: _familyNameCtrl,
                              adminName: _adminNameCtrl,
                            )
                          : _JoinForm(
                              key: const ValueKey('join'),
                              code: _codeCtrl,
                              memberName: _memberNameCtrl,
                              role: _role,
                              onRoleChange: (r) => setState(() => _role = r),
                            ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: NexoSpace.lg),
                      _ErrorBanner(message: _errorText!),
                    ],
                    const SizedBox(height: NexoSpace.xl),
                    AppButton(
                      label: _mode == _Mode.create ? 'Criar família' : 'Entrar na família',
                      loading: _loading,
                      onPressed: _submit,
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

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.value, required this.onChanged});
  final _Mode value;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? NexoColors.darkSurfaceMuted : NexoColors.lightSurfaceMuted;
    final border = dark ? NexoColors.darkBorder : NexoColors.lightBorder;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: muted,
        borderRadius: BorderRadius.circular(NexoRadius.md),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _SegmentTile(
            label: 'Criar família',
            icon: Icons.add_home_outlined,
            selected: value == _Mode.create,
            onTap: () => onChanged(_Mode.create),
          ),
          _SegmentTile(
            label: 'Tenho código',
            icon: Icons.key_outlined,
            selected: value == _Mode.join,
            onTap: () => onChanged(_Mode.join),
          ),
        ],
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = dark ? NexoColors.darkSurface : NexoColors.lightSurface;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: NexoMotion.normal,
          curve: NexoMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(NexoRadius.sm),
            boxShadow: selected ? NexoElevation.card : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? fg : fgMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: NexoText.sm,
                  fontWeight: FontWeight.w600,
                  color: selected ? fg : fgMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateForm extends StatelessWidget {
  const _CreateForm({super.key, required this.familyName, required this.adminName});
  final TextEditingController familyName;
  final TextEditingController adminName;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Nome da família',
          controller: familyName,
          icon: Icons.home_outlined,
          hint: 'Família Silva',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: NexoSpace.lg),
        AppTextField(
          label: 'Como você se chama',
          controller: adminName,
          icon: Icons.person_outline,
          hint: 'Maria',
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.givenName],
        ),
        const SizedBox(height: NexoSpace.md),
        Container(
          padding: const EdgeInsets.all(NexoSpace.md),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(NexoRadius.sm),
            border: Border.all(color: accent.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Você será admin: define regras, gerencia membros e recompensas.',
                  style: TextStyle(
                    fontSize: NexoText.sm,
                    color: accent,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JoinForm extends StatelessWidget {
  const _JoinForm({
    super.key,
    required this.code,
    required this.memberName,
    required this.role,
    required this.onRoleChange,
  });
  final TextEditingController code;
  final TextEditingController memberName;
  final String role;
  final ValueChanged<String> onRoleChange;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Código de convite',
          controller: code,
          icon: Icons.key_outlined,
          hint: 'NEXO42',
          textCapitalization: TextCapitalization.characters,
          helper: '6 letras/números recebidos do admin.',
        ),
        const SizedBox(height: NexoSpace.lg),
        AppTextField(
          label: 'Como você se chama',
          controller: memberName,
          icon: Icons.person_outline,
          hint: 'João',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: NexoSpace.lg),
        Text(
          'VOCÊ É',
          style: TextStyle(
            fontSize: NexoText.xs,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: fgMuted,
          ),
        ),
        const SizedBox(height: NexoSpace.sm),
        Row(
          children: [
            Expanded(
              child: _RolePill(
                label: 'Adulto',
                icon: Icons.person_outline,
                selected: role == 'adult',
                onTap: () => onRoleChange('adult'),
                fg: fg,
                fgMuted: fgMuted,
              ),
            ),
            const SizedBox(width: NexoSpace.md),
            Expanded(
              child: _RolePill(
                label: 'Filho/a',
                icon: Icons.child_care_outlined,
                selected: role == 'child',
                onTap: () => onRoleChange('child'),
                fg: fg,
                fgMuted: fgMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.fg,
    required this.fgMuted,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color fg;
  final Color fgMuted;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NexoMotion.normal,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(NexoRadius.md),
          border: Border.all(
            color: selected ? accent : (dark ? NexoColors.darkBorder : NexoColors.lightBorder),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? accent : fgMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: NexoText.sm,
                fontWeight: FontWeight.w600,
                color: selected ? accent : fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final danger = dark ? NexoColors.dangerDark : NexoColors.danger;
    return Container(
      padding: const EdgeInsets.all(NexoSpace.md),
      decoration: BoxDecoration(
        color: danger.withOpacity(0.10),
        borderRadius: BorderRadius.circular(NexoRadius.sm),
        border: Border.all(color: danger.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: NexoText.sm, color: danger, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
