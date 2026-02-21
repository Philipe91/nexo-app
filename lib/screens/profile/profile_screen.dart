import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/models/member_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Labels de papel e emojis
  static const Map<String, Map<String, String>> _roleLabels = {
    'admin': {'label': 'Admin', 'emoji': '👑'},
    'adult': {'label': 'Adulto', 'emoji': '🧑'},
    'child': {'label': 'Filho/a', 'emoji': '👦'},
  };

  // Relações familiares pré-definidas
  static const List<Map<String, String>> _relationships = [
    {'label': 'Pai', 'emoji': '👨'},
    {'label': 'Mãe', 'emoji': '👩'},
    {'label': 'Filho', 'emoji': '👦'},
    {'label': 'Filha', 'emoji': '👧'},
    {'label': 'Avô', 'emoji': '👴'},
    {'label': 'Avó', 'emoji': '👵'},
    {'label': 'Tio/a', 'emoji': '🧑'},
    {'label': 'Outro', 'emoji': '👤'},
  ];

  // XP necessário por nível
  int _xpForNextLevel(int level) => level * 1000;
  double _xpProgress(Member m) {
    final levelXp = _xpForNextLevel(m.level);
    final prevXp = _xpForNextLevel(m.level - 1);
    return ((m.xp - prevXp) / (levelXp - prevXp)).clamp(0.0, 1.0);
  }

  // Editar RelationShip
  Future<void> _editRelationship(BuildContext ctx, Member member, MemberProvider mp) async {
    await showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quem você é na família?',
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _relationships.map((r) {
                final selected = member.relationship == r['label'];
                return GestureDetector(
                  onTap: () async {
                    final updated = Member(
                      id: member.id,
                      userId: member.userId,
                      familyId: member.familyId,
                      name: member.name,
                      role: member.role,
                      color: member.color,
                      joinedAt: member.joinedAt,
                      xp: member.xp,
                      level: member.level,
                      coins: member.coins,
                      badges: member.badges,
                      relationship: r['label']!,
                    );
                    await mp.updateMember(updated);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF4E5AE8) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected ? const Color(0xFF4E5AE8) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '${r['emoji']} ${r['label']}',
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Editar Nome
  Future<void> _editName(BuildContext ctx, Member member, MemberProvider mp) async {
    final ctrl = TextEditingController(text: member.name);
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Alterar nome', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Seu nome',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                final updated = Member(
                  id: member.id,
                  userId: member.userId,
                  familyId: member.familyId,
                  name: ctrl.text.trim(),
                  role: member.role,
                  color: member.color,
                  joinedAt: member.joinedAt,
                  xp: member.xp,
                  level: member.level,
                  coins: member.coins,
                  badges: member.badges,
                  relationship: member.relationship,
                );
                await mp.updateMember(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mp = context.watch<MemberProvider>();
    final member = mp.currentMember;

    final roleInfo = _roleLabels[member?.role ?? 'adult'] ?? {'label': 'Adulto', 'emoji': '🧑'};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── AppBar com avatar ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: Tooltip(
              message: 'Voltar',
              child: BackButton(
                onPressed: () => context.pop(),
                color: Colors.white,
              ),
            ),
            actions: [
              if (member != null)
                Tooltip(
                  message: 'Editar nome',
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => _editName(context, member, mp),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      GestureDetector(
                        onTap: member != null ? () => _editRelationship(context, member, mp) : null,
                        child: Semantics(
                          label: 'Avatar de ${member?.name ?? 'Usuário'}',
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: member != null
                                  ? Color(int.tryParse(member.color) ?? 0xFF4D5BCE)
                                  : const Color(0xFF4D5BCE),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                member != null && member.name.isNotEmpty
                                    ? member.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 10),
                      Text(
                        member?.name ?? auth.appUser?.name ?? 'Usuário',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Papel + Relação
                      GestureDetector(
                        onTap: member != null ? () => _editRelationship(context, member, mp) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_getRelationshipEmoji(member?.relationship)} ${member?.relationship ?? 'Familiar'}  •  ${roleInfo['emoji']} ${roleInfo['label']}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Conteúdo ───
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // XP Card
                if (member != null) ...[
                  _buildXpCard(member),
                  const SizedBox(height: 12),
                  _buildStatsRow(member),
                  const SizedBox(height: 20),
                ],

                // Email
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'E-mail',
                  value: auth.appUser?.email ?? auth.firebaseUser?.email ?? '—',
                ),

                const SizedBox(height: 8),

                // Badges
                if (member != null && member.badges.isNotEmpty) ...[
                  _buildSectionLabel('Conquistas'),
                  _buildBadges(member.badges),
                  const SizedBox(height: 20),
                ],

                // Sair
                const SizedBox(height: 8),
                _buildSectionLabel('Conta'),
                _buildLogoutButton(context, auth),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getRelationshipEmoji(String? rel) {
    final r = _relationships.firstWhere(
      (e) => e['label'] == rel,
      orElse: () => {'label': 'Outro', 'emoji': '👤'},
    );
    return r['emoji']!;
  }

  Widget _buildXpCard(Member member) {
    final progress = _xpProgress(member);
    final xpNeeded = _xpForNextLevel(member.level) - member.xp;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E5AE8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text('Nível ${member.level}',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
              const Spacer(),
              Text('${member.xp} XP total',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text('Faltam $xpNeeded XP para o próximo nível',
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsRow(Member member) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('🪙', '${member.coins}', 'Moedas', const Color(0xFFFFB800))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('⚔️', '${member.level}', 'Nível', const Color(0xFF4E5AE8))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('🏅', '${member.badges.length}', 'Badges', const Color(0xFF43cea2))),
      ],
    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              )),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4E5AE8), size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          )),
    );
  }

  Widget _buildBadges(List<String> badges) {
    final badgeEmojis = {'first_task': '🥇', 'streak_7': '🔥', 'level_5': '⭐', 'team_player': '🤝'};
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((b) {
        return Tooltip(
          message: b,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(badgeEmojis[b] ?? '🏅 $b', style: const TextStyle(fontSize: 15)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return Semantics(
      label: 'Sair da conta',
      button: true,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Sair da conta?'),
              content: const Text('Você precisará fazer login novamente.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sair'),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await auth.signOut();
            context.go('/splash');
          }
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text('Sair da conta', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
