import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/member_model.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/handoff_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toast.dart';

class HandoffSheet {
  static Future<void> show(BuildContext context, Task task) {
    return AppBottomSheet.show(
      context: context,
      title: 'Passar o bastão',
      subtitle: 'Por quanto tempo e pra quem você quer transferir essa tarefa?',
      child: _Form(task: task),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.task});
  final Task task;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  int _days = 3;
  String? _toMember;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;

    final members = context.watch<MemberProvider>().members;
    // Tira o atual responsável (whoExecutes) — não faz sentido transferir pra ele.
    final candidates = members.where((m) => m.name != widget.task.whoExecutes).toList();

    if (candidates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(LucideIcons.users, size: 32, color: NexoColors.indigo),
            const SizedBox(height: NexoSpace.md),
            Text(
              'Adicione mais membros pra poder passar o bastão.',
              textAlign: TextAlign.center,
              style: TextStyle(color: fgMuted),
            ),
          ],
        ),
      );
    }

    _toMember ??= candidates.first.name;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Tarefa ──
          Container(
            padding: const EdgeInsets.all(NexoSpace.md),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(NexoRadius.sm),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.helpingHand, color: accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: AppTheme.display(
                            size: NexoText.base, weight: FontWeight.w700, color: fg),
                      ),
                      Text(
                        'De ${widget.task.whoExecutes}',
                        style: TextStyle(fontSize: NexoText.xs, color: fgMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: NexoSpace.lg),
          // ── Quem recebe ──
          Text(
            'PRA QUEM',
            style: TextStyle(
              fontSize: NexoText.xs,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: fgMuted,
            ),
          ),
          const SizedBox(height: NexoSpace.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: candidates.map((m) {
              final color = Color(int.tryParse(m.color) ?? 0xFF5E6AD2);
              final selected = _toMember == m.name;
              return _MemberPill(
                member: m,
                color: color,
                selected: selected,
                onTap: () => setState(() => _toMember = m.name),
              );
            }).toList(),
          ),

          const SizedBox(height: NexoSpace.lg),
          // ── Por quantos dias ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POR QUANTOS DIAS',
                style: TextStyle(
                  fontSize: NexoText.xs,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: fgMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(NexoRadius.pill),
                ),
                child: Text(
                  '$_days ${_days == 1 ? "dia" : "dias"}',
                  style: AppTheme.mono(
                    size: NexoText.sm,
                    weight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 14,
            divisions: 13,
            label: '$_days',
            activeColor: accent,
            onChanged: (v) => setState(() => _days = v.round()),
          ),

          const SizedBox(height: NexoSpace.md),
          // ── Resumo ──
          Container(
            padding: const EdgeInsets.all(NexoSpace.md),
            decoration: BoxDecoration(
              color: dark ? NexoColors.darkSurfaceMuted : NexoColors.lightSurfaceMuted,
              borderRadius: BorderRadius.circular(NexoRadius.sm),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, color: fgMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Volta automático para ${widget.task.whoExecutes} em $_days ${_days == 1 ? "dia" : "dias"}.',
                    style: TextStyle(fontSize: NexoText.sm, color: fgMuted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: NexoSpace.xl),
          AppButton(
            label: _saving ? 'Passando...' : 'Passar bastão pra $_toMember',
            icon: LucideIcons.arrowRight,
            loading: _saving,
            onPressed: _toMember == null ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_toMember == null) return;
    setState(() => _saving = true);
    final result = await context.read<HandoffProvider>().start(
          taskId: widget.task.id,
          taskTitle: widget.task.title,
          fromMemberName: widget.task.whoExecutes,
          toMemberName: _toMember!,
          days: _days,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    if (result != null) {
      AppToast.show(
        context,
        'Bastão com $_toMember por $_days ${_days == 1 ? "dia" : "dias"}',
        kind: AppToastKind.success,
      );
    } else {
      AppToast.show(context, 'Não consegui passar o bastão agora.', kind: AppToastKind.danger);
    }
  }
}

class _MemberPill extends StatelessWidget {
  const _MemberPill({
    required this.member,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Member member;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NexoMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(NexoRadius.pill),
          border: Border.all(
            color: selected ? color : (dark ? NexoColors.darkBorder : NexoColors.lightBorder),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: NexoText.xs,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              member.name,
              style: TextStyle(
                fontSize: NexoText.sm,
                fontWeight: FontWeight.w600,
                color: selected ? color : fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
