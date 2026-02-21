import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/services/family_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _inviteCode;
  bool _loadingCode = false;

  @override
  void initState() {
    super.initState();
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    final auth = context.read<AuthProvider>();
    final familyId = auth.appUser?.currentFamilyId;
    if (familyId == null) return;
    setState(() => _loadingCode = true);
    final code = await FamilyService().getInviteCode(familyId);
    if (mounted) setState(() { _inviteCode = code; _loadingCode = false; });
  }

  Future<void> _resetApp(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Apagar tudo?'),
        content: const Text('Isso encerrará sua sessão e limpará os dados locais.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirm == true && ctx.mounted) {
      await ctx.read<AuthProvider>().signOut();
      ctx.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final auth = context.watch<AuthProvider>();
    final mp = context.watch<MemberProvider>();
    final member = mp.currentMember;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        centerTitle: true,
        leading: Tooltip(
          message: 'Voltar',
          child: BackButton(onPressed: () => context.pop()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [

          // ── Seção: Perfil ──
          _buildSectionHeader('👤 Minha Conta'),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.account_circle_outlined,
              iconColor: const Color(0xFF4E5AE8),
              title: member?.name ?? auth.appUser?.name ?? 'Meu Perfil',
              subtitle: _roleLabel(member?.role) + (member?.relationship != null ? ' • ${member!.relationship}' : ''),
              onTap: () => context.push('/profile'),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Seção: Família ──
          _buildSectionHeader('👨‍👩‍👧 Família'),
          _buildCard(children: [
            // Código de convite
            _buildInviteCodeTile(),
            const Divider(height: 1, indent: 16),
            _buildNavTile(
              icon: Icons.people_outline,
              iconColor: Colors.purple,
              title: 'Membros da Família',
              subtitle: '${mp.members.length} pessoas',
              onTap: () => context.push('/members'),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Seção: Aparência ──
          _buildSectionHeader('🎨 Aparência'),
          _buildCard(children: [
            SwitchListTile(
              secondary: Semantics(
                label: 'Ícone modo escuro',
                child: Icon(
                  prefs.isDarkMode ? Icons.dark_mode : Icons.light_mode_outlined,
                  color: const Color(0xFF4E5AE8),
                ),
              ),
              title: const Text('Modo Escuro'),
              subtitle: Text(prefs.isDarkMode ? 'Tema escuro ativado' : 'Tema claro ativado'),
              value: prefs.isDarkMode ?? false,
              onChanged: (val) => prefs.toggleTheme(val),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Seção: Modo Filho ──
          _buildSectionHeader('🎮 Modo Filho'),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.storefront_outlined,
              iconColor: Colors.orange,
              title: 'Loja de Prêmios',
              subtitle: 'Gerenciar prêmios que os filhos podem resgatar',
              onTap: () => context.push('/manage-rewards'),
            ),
            const Divider(height: 1, indent: 16),
            _buildNavTile(
              icon: Icons.account_balance_outlined,
              iconColor: Colors.green,
              title: 'Banco da Família',
              subtitle: 'Pagar mesada e ver saldo',
              onTap: () => context.push('/manage-bank'),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Seção: Acessibilidade ──
          _buildSectionHeader('♿ Acessibilidade'),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.text_increase,
              iconColor: Colors.teal,
              title: 'Tamanho do Texto',
              subtitle: 'Controlado pelo sistema Android/iOS',
              onTap: null,
            ),
          ]),

          const SizedBox(height: 16),

          // ── Seção: Sobre ──
          _buildSectionHeader('ℹ️ Sobre'),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.info_outline,
              iconColor: Colors.blueGrey,
              title: 'Nexo App',
              subtitle: 'Versão 1.2.0 — Fevereiro 2026',
              onTap: null,
            ),
            const Divider(height: 1, indent: 16),
            _buildNavTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: Colors.blueGrey,
              title: 'Política de Privacidade',
              subtitle: 'Seus dados são seus',
              onTap: null,
            ),
          ]),

          const SizedBox(height: 16),

          // ── Sair / Resetar ──
          _buildSectionHeader('⚠️ Conta'),
          _buildCard(children: [
            Semantics(
              label: 'Sair da conta',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Sair da conta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) context.go('/splash');
                },
              ),
            ),
            const Divider(height: 1, indent: 16),
            Semantics(
              label: 'Resetar aplicativo',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                title: const Text('Resetar Aplicativo', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Encerra sessão e limpa dados locais'),
                onTap: () => _resetApp(context),
              ),
            ),
          ]),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'NEXO v1.2.0 • Feito com ❤️',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInviteCodeTile() {
    return ListTile(
      leading: const Icon(Icons.vpn_key_outlined, color: Color(0xFF4E5AE8)),
      title: const Text('Código de Convite', style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: _loadingCode
          ? const Text('Carregando...')
          : Text(
              _inviteCode ?? '—',
              style: GoogleFonts.sourceCodePro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4E5AE8),
                letterSpacing: 4,
              ),
            ),
      trailing: _inviteCode != null
          ? Tooltip(
              message: 'Copiar código',
              child: IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _inviteCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Código $_inviteCode copiado!'),
                      backgroundColor: const Color(0xFF4E5AE8),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Semantics(
      button: onTap != null,
      label: title,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
        onTap: onTap,
        minVerticalPadding: 14,
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin': return '👑 Admin';
      case 'adult': return '🧑 Adulto';
      case 'child': return '👦 Filho/a';
      default: return '👤';
    }
  }
}