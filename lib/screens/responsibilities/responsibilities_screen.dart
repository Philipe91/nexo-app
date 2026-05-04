import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/task_model.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_segmented_control.dart';
import '../../core/widgets/app_toast.dart';
import 'add_responsibility_screen.dart' show SeasonalSeedSheet;

enum _Filter { hoje, todas, sazonais }

const _dayCodes = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

class ResponsibilitiesScreen extends StatefulWidget {
  const ResponsibilitiesScreen({super.key});

  @override
  State<ResponsibilitiesScreen> createState() => _ResponsibilitiesScreenState();
}

class _ResponsibilitiesScreenState extends State<ResponsibilitiesScreen> {
  _Filter _filter = _Filter.hoje;
  String? _memberFilter; // nome do membro (compatível com whoExecutes)

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    final taskProvider = context.watch<TaskProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final allTasks = taskProvider.tasks;
    final members = memberProvider.members;

    final List<Task> base;
    switch (_filter) {
      case _Filter.hoje:
        final todayCode = _dayCodes[DateTime.now().weekday % 7];
        base = allTasks.where((t) => t.days.contains(todayCode)).toList();
      case _Filter.sazonais:
        base = allTasks.where((t) => t.isSazonal).toList();
      case _Filter.todas:
        base = allTasks;
    }

    final filtered = _memberFilter == null
        ? base
        : base
            .where((t) =>
                t.whoRemembers == _memberFilter ||
                t.whoDecides == _memberFilter ||
                t.whoExecutes == _memberFilter)
            .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Responsabilidades'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: fg),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_filter == _Filter.sazonais)
            IconButton(
              tooltip: 'Sugestões comuns',
              icon: Icon(LucideIcons.sparkles, color: fg),
              onPressed: () => SeasonalSeedSheet.show(context),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/responsibilities/add'),
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Nova tarefa'),
      ),
      body: AmbientBackground(
        intensity: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 56),
              Padding(
                padding: const EdgeInsets.fromLTRB(NexoSpace.xl, NexoSpace.md, NexoSpace.xl, 0),
                child: AppSegmentedControl(
                  value: _filter.name,
                  onChanged: (v) => setState(() => _filter = _Filter.values.firstWhere((e) => e.name == v)),
                  segments: const [
                    AppSegment(value: 'hoje', label: 'Hoje', icon: LucideIcons.sun),
                    AppSegment(value: 'todas', label: 'Todas', icon: LucideIcons.list),
                    AppSegment(value: 'sazonais', label: 'Sazonais', icon: LucideIcons.calendarClock),
                  ],
                ),
              ),
              if (members.isNotEmpty) ...[
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: NexoSpace.xl, vertical: NexoSpace.md),
                    children: [
                      AppChip(
                        label: 'Todos',
                        icon: LucideIcons.users,
                        selected: _memberFilter == null,
                        onTap: () => setState(() => _memberFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...members.map((m) {
                        final color = Color(int.tryParse(m.color) ?? 0xFF5E6AD2);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppChip(
                            label: m.name,
                            color: color,
                            selected: _memberFilter == m.name,
                            onTap: () => setState(() => _memberFilter = m.name),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: filtered.isEmpty
                    ? _Empty(
                        filter: _filter,
                        onSeed: () => SeasonalSeedSheet.show(context),
                        onCreate: () => context.push('/responsibilities/add'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            NexoSpace.xl, NexoSpace.sm, NexoSpace.xl, 100),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: NexoSpace.md),
                          child: _TaskTile(
                            task: filtered[i],
                            members: members,
                            onComplete: () async {
                              final completed =
                                  await taskProvider.toggleTaskCompletion(filtered[i].id);
                              if (!mounted) return;
                              AppToast.show(
                                context,
                                completed ? 'Tarefa concluída' : 'Concluído desfeito',
                                kind: AppToastKind.success,
                              );
                            },
                            onEdit: () => context.push('/responsibilities/edit', extra: filtered[i]),
                            onDelete: () async {
                              await taskProvider.removeTask(filtered[i].id);
                              if (!mounted) return;
                              AppToast.show(context, 'Tarefa removida', kind: AppToastKind.info);
                            },
                            fg: fg,
                            fgMuted: fgMuted,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.members,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.fg,
    required this.fgMuted,
  });

  final Task task;
  final List<dynamic> members;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color fg;
  final Color fgMuted;

  Color _effortColor() {
    switch (task.effort) {
      case 1:
        return NexoColors.success;
      case 2:
        return NexoColors.warning;
      case 3:
        return NexoColors.danger;
      default:
        return NexoColors.indigo;
    }
  }

  String _effortLabel() {
    switch (task.effort) {
      case 1:
        return 'Leve';
      case 2:
        return 'Médio';
      case 3:
        return 'Pesado';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _effortColor();
    final isDone = task.isCompletedToday;

    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(NexoSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox custom
              GestureDetector(
                onTap: onComplete,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: NexoMotion.normal,
                  curve: NexoMotion.standard,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: isDone
                      ? const Icon(LucideIcons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: NexoSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTheme.display(
                        size: NexoText.base,
                        weight: FontWeight.w700,
                        color: fg,
                      ).copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: fgMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.frequency,
                      style: TextStyle(fontSize: NexoText.xs, color: fgMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(NexoRadius.pill),
                ),
                child: Text(
                  _effortLabel(),
                  style: TextStyle(
                    fontSize: NexoText.xs,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NexoSpace.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaTag(icon: LucideIcons.brain, label: task.whoRemembers, color: const Color(0xFF8B5CF6)),
              _MetaTag(icon: LucideIcons.scale, label: task.whoDecides, color: const Color(0xFF06B6D4)),
              _MetaTag(icon: LucideIcons.zap, label: task.whoExecutes, color: const Color(0xFFF97316)),
              if (task.invisibleCount > 0)
                _MetaTag(
                  icon: LucideIcons.layers,
                  label: '${task.invisibleDoneCount}/${task.invisibleCount} invisíveis',
                  color: NexoColors.indigo,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(NexoRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: NexoText.xs,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filter, required this.onSeed, required this.onCreate});
  final _Filter filter;
  final VoidCallback onSeed;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    final (title, msg, icon) = switch (filter) {
      _Filter.hoje => (
          'Sua casa está leve hoje',
          'Aproveite. Quando precisar, é só criar uma nova tarefa.',
          LucideIcons.sunrise,
        ),
      _Filter.todas => (
          'Nenhuma responsabilidade ainda',
          'Adicione a primeira pra começar a equilibrar a casa.',
          LucideIcons.listTodo,
        ),
      _Filter.sazonais => (
          'Sem sazonais cadastradas',
          'Que tal escolher entre as sugestões mais comuns?',
          LucideIcons.calendarClock,
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NexoSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: NexoColors.indigo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(NexoRadius.lg),
                border: Border.all(color: NexoColors.indigo.withOpacity(0.20)),
              ),
              child: Icon(icon, color: NexoColors.indigo, size: 32),
            ),
            const SizedBox(height: NexoSpace.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.display(size: NexoText.xl, weight: FontWeight.w800, color: fg),
            ),
            const SizedBox(height: NexoSpace.sm),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: NexoText.sm, color: fgMuted, height: 1.45),
            ),
            const SizedBox(height: NexoSpace.xl),
            if (filter == _Filter.sazonais)
              AppButton(
                label: 'Ver sugestões',
                icon: LucideIcons.sparkles,
                onPressed: onSeed,
                fullWidth: false,
              )
            else
              AppButton(
                label: 'Nova tarefa',
                icon: LucideIcons.plus,
                onPressed: onCreate,
                fullWidth: false,
              ),
          ],
        ),
      ),
    );
  }
}
