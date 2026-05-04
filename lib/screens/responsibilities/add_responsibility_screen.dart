import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/member_model.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/section_header.dart';

class AddResponsibilityScreen extends StatefulWidget {
  const AddResponsibilityScreen({super.key, this.taskToEdit});

  final Task? taskToEdit;

  @override
  State<AddResponsibilityScreen> createState() => _AddResponsibilityScreenState();
}

class _AddResponsibilityScreenState extends State<AddResponsibilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();

  String? _whoRemembers;
  String? _whoDecides;
  String? _whoExecutes;
  String _frequency = TaskFrequency.semanal;
  int _effort = 1;
  final List<String> _selectedDays = [];

  bool _notifyAtTime = false;
  TimeOfDay? _selectedTime;
  bool _showSubtasksSection = false;

  // Iceberg — subtarefas invisíveis
  final List<SubTask> _hiddenSubtasks = [];

  // Áudio
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _recordedPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  static const _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  void initState() {
    super.initState();

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final members = context.read<MemberProvider>().members.map((m) => m.name).toList();
      if (members.isEmpty) return;
      setState(() {
        final t = widget.taskToEdit;
        if (t != null) {
          _titleCtrl.text = t.title;
          _whoRemembers = members.contains(t.whoRemembers) ? t.whoRemembers : members.first;
          _whoDecides = members.contains(t.whoDecides) ? t.whoDecides : members.first;
          _whoExecutes = members.contains(t.whoExecutes) ? t.whoExecutes : members.first;
          _effort = t.effort;
          _frequency = TaskFrequency.all.contains(t.frequency) ? t.frequency : TaskFrequency.semanal;
          _selectedDays
            ..clear()
            ..addAll(t.days);
          _notifyAtTime = t.notifyAtTime;
          if (t.scheduledTime != null) {
            _selectedTime = TimeOfDay.fromDateTime(t.scheduledTime!);
          }
          _recordedPath = t.audioPath;
          _hiddenSubtasks
            ..clear()
            ..addAll(t.hiddenSubtasks);
          _showSubtasksSection = _hiddenSubtasks.isNotEmpty;
        } else {
          _whoRemembers = members.first;
          _whoDecides = members.length > 1 ? members[1] : members.first;
          _whoExecutes = members.first;
        }
      });
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtaskCtrl.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Audio actions ──────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/audio_${const Uuid().v4()}.m4a';
        await _recorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      } else {
        AppToast.show(context, 'Permissão de microfone negada.', kind: AppToastKind.warning);
      }
    } catch (e) {
      AppToast.show(context, 'Não consegui gravar agora.', kind: AppToastKind.danger);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordedPath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_recordedPath != null) {
      await _player.play(DeviceFileSource(_recordedPath!));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  Future<void> _deleteRecording() async {
    await _player.stop();
    setState(() {
      _recordedPath = null;
      _isPlaying = false;
    });
  }

  // ── Subtask actions ────────────────────────────────────────────────────────
  void _addSubtask() {
    final t = _subtaskCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _hiddenSubtasks.add(SubTask(id: const Uuid().v4(), title: t));
      _subtaskCtrl.clear();
    });
  }

  void _removeSubtask(String id) {
    setState(() => _hiddenSubtasks.removeWhere((s) => s.id == id));
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_whoRemembers == null || _whoDecides == null || _whoExecutes == null) return;

    DateTime? scheduledDateTime;
    if (_notifyAtTime && _selectedTime != null) {
      final now = DateTime.now();
      var dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
      if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
      scheduledDateTime = dt;
    }

    final provider = context.read<TaskProvider>();
    final isEdit = widget.taskToEdit != null;

    if (isEdit) {
      await provider.updateTask(widget.taskToEdit!.copyWith(
        title: _titleCtrl.text.trim(),
        whoRemembers: _whoRemembers!,
        whoDecides: _whoDecides!,
        whoExecutes: _whoExecutes!,
        effort: _effort,
        frequency: _frequency,
        days: _selectedDays,
        notifyAtTime: _notifyAtTime,
        scheduledTime: scheduledDateTime,
        audioPath: _recordedPath,
        hiddenSubtasks: _hiddenSubtasks,
      ));
    } else {
      await provider.addTask(
        title: _titleCtrl.text.trim(),
        whoRemembers: _whoRemembers!,
        whoDecides: _whoDecides!,
        whoExecutes: _whoExecutes!,
        effort: _effort,
        frequency: _frequency,
        days: _selectedDays,
        notifyAtTime: _notifyAtTime,
        scheduledTime: scheduledDateTime,
        audioPath: _recordedPath,
        hiddenSubtasks: _hiddenSubtasks,
      );
    }

    if (!mounted) return;
    AppToast.show(
      context,
      isEdit ? 'Tarefa atualizada' : 'Tarefa criada',
      kind: AppToastKind.success,
    );
    context.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    final accent = dark ? NexoColors.indigoSoft : NexoColors.indigo;

    final members = context.watch<MemberProvider>().members;
    final memberNames = members.map((m) => m.name).toList();

    if (memberNames.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: _EmptyMembers(
          onAdd: () => context.push('/members'),
        ),
      );
    }

    _whoRemembers ??= memberNames.first;
    _whoDecides ??= memberNames.first;
    _whoExecutes ??= memberNames.first;

    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
          tooltip: 'Fechar',
        ),
        title: Text(isEditing ? 'Editar tarefa' : 'Nova responsabilidade'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(NexoSpace.xl, NexoSpace.lg, NexoSpace.xl, NexoSpace.xxxl),
          children: [
            // ── Título ────────────────────────────────────────────────────
            AppTextField(
              label: 'O que precisa ser feito?',
              controller: _titleCtrl,
              icon: LucideIcons.edit3,
              hint: 'Ex: Pagar conta de luz',
            ),

            const SizedBox(height: NexoSpace.xl),

            // ── L.D.E ─────────────────────────────────────────────────────
            const SectionHeader(
              title: 'Os 3 donos da tarefa',
              subtitle: 'Lembrar, decidir e executar contam pontos separados.',
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: NexoSpace.lg, vertical: NexoSpace.sm),
              child: Column(
                children: [
                  _RoleRow(
                    icon: LucideIcons.brain,
                    label: 'Quem lembra',
                    color: const Color(0xFF8B5CF6),
                    value: _whoRemembers!,
                    members: members,
                    onChanged: (v) => setState(() => _whoRemembers = v),
                  ),
                  const Divider(height: 1),
                  _RoleRow(
                    icon: LucideIcons.scale,
                    label: 'Quem decide',
                    color: const Color(0xFF06B6D4),
                    value: _whoDecides!,
                    members: members,
                    onChanged: (v) => setState(() => _whoDecides = v),
                  ),
                  const Divider(height: 1),
                  _RoleRow(
                    icon: LucideIcons.zap,
                    label: 'Quem executa',
                    color: const Color(0xFFF97316),
                    value: _whoExecutes!,
                    members: members,
                    onChanged: (v) => setState(() => _whoExecutes = v),
                  ),
                ],
              ),
            ),

            // ── Frequência + esforço ──────────────────────────────────────
            const SectionHeader(title: 'Quando e quanto pesa'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Frequência', style: TextStyle(fontSize: NexoText.sm, color: fgMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TaskFrequency.all.map((f) {
                      return AppChip(
                        label: f,
                        selected: _frequency == f,
                        icon: TaskFrequency.isSazonal(f) ? LucideIcons.calendarClock : null,
                        onTap: () => setState(() => _frequency = f),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: NexoSpace.lg),
                  Text('Esforço', style: TextStyle(fontSize: NexoText.sm, color: fgMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _EffortPill(
                        selected: _effort == 1,
                        label: 'Leve',
                        color: NexoColors.success,
                        onTap: () => setState(() => _effort = 1),
                      ),
                      const SizedBox(width: 8),
                      _EffortPill(
                        selected: _effort == 2,
                        label: 'Médio',
                        color: NexoColors.warning,
                        onTap: () => setState(() => _effort = 2),
                      ),
                      const SizedBox(width: 8),
                      _EffortPill(
                        selected: _effort == 3,
                        label: 'Pesado',
                        color: NexoColors.danger,
                        onTap: () => setState(() => _effort = 3),
                      ),
                    ],
                  ),
                  if (!TaskFrequency.isSazonal(_frequency)) ...[
                    const SizedBox(height: NexoSpace.lg),
                    Text('Em quais dias', style: TextStyle(fontSize: NexoText.sm, color: fgMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _weekDays.map((d) {
                        return AppChip(
                          label: d,
                          selected: _selectedDays.contains(d),
                          onTap: () => setState(() {
                            if (_selectedDays.contains(d)) {
                              _selectedDays.remove(d);
                            } else {
                              _selectedDays.add(d);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // ── ICEBERG: trabalho invisível ───────────────────────────────
            const SectionHeader(
              title: 'Trabalho invisível',
              subtitle: 'Lembrar de decidir, planejar, conferir — pesa também.',
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showSubtasksSection = !_showSubtasksSection),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(NexoRadius.sm),
                          ),
                          child: Icon(LucideIcons.layers, color: accent, size: 18),
                        ),
                        const SizedBox(width: NexoSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hiddenSubtasks.isEmpty
                                    ? 'Adicionar partes invisíveis'
                                    : '${_hiddenSubtasks.length} ${_hiddenSubtasks.length == 1 ? "parte" : "partes"} invisível${_hiddenSubtasks.length == 1 ? "" : "is"}',
                                style: AppTheme.display(size: NexoText.base, weight: FontWeight.w700, color: fg),
                              ),
                              Text(
                                'Cada parte conta como meio ponto de carga.',
                                style: TextStyle(fontSize: NexoText.xs, color: fgMuted),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _showSubtasksSection ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          color: fgMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  if (_showSubtasksSection) ...[
                    const SizedBox(height: NexoSpace.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskCtrl,
                            onSubmitted: (_) => _addSubtask(),
                            decoration: const InputDecoration(
                              hintText: 'Ex: checar o estoque antes',
                              prefixIcon: Icon(LucideIcons.plus, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          label: 'Adicionar',
                          size: AppButtonSize.md,
                          fullWidth: false,
                          variant: AppButtonVariant.secondary,
                          onPressed: _addSubtask,
                        ),
                      ],
                    ),
                    if (_hiddenSubtasks.isNotEmpty) ...[
                      const SizedBox(height: NexoSpace.md),
                      ..._hiddenSubtasks.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(LucideIcons.dot, color: accent, size: 18),
                              Expanded(
                                child: Text(
                                  s.title,
                                  style: TextStyle(color: fg, fontSize: NexoText.sm),
                                ),
                              ),
                              IconButton(
                                icon: Icon(LucideIcons.trash2, size: 16, color: fgMuted),
                                tooltip: 'Remover',
                                onPressed: () => _removeSubtask(s.id),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),

            // ── Notificação ───────────────────────────────────────────────
            const SectionHeader(title: 'Lembrete'),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(NexoRadius.sm),
                        ),
                        child: Icon(LucideIcons.bell, color: accent, size: 18),
                      ),
                      const SizedBox(width: NexoSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notificar no horário',
                              style: AppTheme.display(size: NexoText.base, weight: FontWeight.w700, color: fg),
                            ),
                            Text(
                              'Lembrete push no momento certo.',
                              style: TextStyle(fontSize: NexoText.xs, color: fgMuted),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _notifyAtTime,
                        activeColor: accent,
                        onChanged: (v) => setState(() => _notifyAtTime = v),
                      ),
                    ],
                  ),
                  if (_notifyAtTime) ...[
                    const SizedBox(height: NexoSpace.md),
                    InkWell(
                      borderRadius: BorderRadius.circular(NexoRadius.sm),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (t != null) setState(() => _selectedTime = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(NexoRadius.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.clock, color: accent, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime?.format(context) ?? 'Escolher horário',
                              style: AppTheme.mono(
                                size: NexoText.base,
                                weight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Áudio ─────────────────────────────────────────────────────
            const SectionHeader(
              title: 'Instrução por voz',
              subtitle: 'Opcional. Útil pra tarefas que precisam de detalhe.',
            ),
            AppCard(
              child: _AudioControls(
                isRecording: _isRecording,
                isPlaying: _isPlaying,
                hasRecording: _recordedPath != null,
                onStart: _startRecording,
                onStop: _stopRecording,
                onPlay: _playRecording,
                onPausePlayback: _stopPlayback,
                onDelete: _deleteRecording,
              ),
            ),

            const SizedBox(height: NexoSpace.xxl),
            AppButton(
              label: isEditing ? 'Salvar alterações' : 'Criar tarefa',
              icon: isEditing ? LucideIcons.check : LucideIcons.plus,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ───────────────────────────────────────────────────────────────────────────

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.members,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final Color color;
  final String value;
  final List<Member> members;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(NexoRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: NexoSpace.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: NexoText.sm, color: fg, fontWeight: FontWeight.w600),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(NexoRadius.md),
            items: members.map((m) {
              return DropdownMenuItem(
                value: m.name,
                child: Text(m.name, style: TextStyle(fontWeight: FontWeight.w600, color: fg)),
              );
            }).toList(),
            onChanged: (v) => v == null ? null : onChanged(v),
          ),
        ],
      ),
    );
  }
}

class _EffortPill extends StatelessWidget {
  const _EffortPill({
    required this.selected,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final bool selected;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? NexoColors.darkBorder : NexoColors.lightBorder;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: NexoMotion.normal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(NexoRadius.sm),
            border: Border.all(color: selected ? color : border, width: selected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: NexoText.sm,
              fontWeight: FontWeight.w700,
              color: selected ? color : (dark ? NexoColors.darkFg : NexoColors.lightFg),
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioControls extends StatelessWidget {
  const _AudioControls({
    required this.isRecording,
    required this.isPlaying,
    required this.hasRecording,
    required this.onStart,
    required this.onStop,
    required this.onPlay,
    required this.onPausePlayback,
    required this.onDelete,
  });

  final bool isRecording;
  final bool isPlaying;
  final bool hasRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPlay;
  final VoidCallback onPausePlayback;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isRecording) {
      return Column(
        children: [
          Text(
            'Gravando',
            style: TextStyle(
              fontSize: NexoText.sm,
              color: NexoColors.danger,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 600.ms).then().fadeOut(duration: 600.ms),
          const SizedBox(height: NexoSpace.md),
          AppButton(
            label: 'Parar gravação',
            icon: LucideIcons.square,
            variant: AppButtonVariant.danger,
            size: AppButtonSize.md,
            onPressed: onStop,
          ),
        ],
      );
    }

    if (!hasRecording) {
      return AppButton(
        label: 'Gravar instrução',
        icon: LucideIcons.mic,
        variant: AppButtonVariant.secondary,
        size: AppButtonSize.md,
        onPressed: onStart,
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: isPlaying ? 'Parar' : 'Tocar',
            icon: isPlaying ? LucideIcons.square : LucideIcons.play,
            size: AppButtonSize.md,
            variant: AppButtonVariant.secondary,
            onPressed: isPlaying ? onPausePlayback : onPlay,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(LucideIcons.trash2),
          tooltip: 'Apagar áudio',
          color: NexoColors.danger,
        ),
      ],
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;
    return Padding(
      padding: const EdgeInsets.all(NexoSpace.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.users, size: 48, color: NexoColors.indigo),
            const SizedBox(height: NexoSpace.md),
            Text(
              'Adicione um membro primeiro',
              style: AppTheme.display(size: NexoText.lg, weight: FontWeight.w700, color: fg),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarefas precisam de pelo menos um responsável.',
              textAlign: TextAlign.center,
              style: TextStyle(color: fgMuted, fontSize: NexoText.sm),
            ),
            const SizedBox(height: NexoSpace.xl),
            AppButton(
              label: 'Ir pra Membros',
              icon: LucideIcons.userPlus,
              onPressed: onAdd,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet com sugestões de tarefas sazonais comuns.
/// Chamar via [SeasonalSeedSheet.show] a partir do botão "Comuns" na lista.
class SeasonalSeedSheet {
  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Tarefas sazonais comuns',
      subtitle: 'Toque pra adicionar com 1 lembrete básico. Ajuste depois.',
      child: _SeedList(),
    );
  }
}

class _SeedList extends StatelessWidget {
  static const _seeds = <(String title, String frequency, IconData icon)>[
    ('Declarar Imposto de Renda', TaskFrequency.anual, LucideIcons.fileText),
    ('Dentista (limpeza)', TaskFrequency.semestral, LucideIcons.stethoscope),
    ('Troca de armário', TaskFrequency.semestral, LucideIcons.shirt),
    ('Vacina anual do pet', TaskFrequency.anual, LucideIcons.dog),
    ('Renovar passaporte', TaskFrequency.anual, LucideIcons.bookOpen),
    ('Renovar CNH', TaskFrequency.anual, LucideIcons.creditCard),
    ('Revisão do carro', TaskFrequency.semestral, LucideIcons.car),
    ('Trocar filtro de água', TaskFrequency.trimestral, LucideIcons.droplet),
    ('Limpeza de ar-condicionado', TaskFrequency.semestral, LucideIcons.wind),
    ('Atualizar cartão de vacinação', TaskFrequency.anual, LucideIcons.syringe),
    ('Revisão financeira do ano', TaskFrequency.anual, LucideIcons.lineChart),
    ('Backup de fotos', TaskFrequency.trimestral, LucideIcons.hardDrive),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? NexoColors.darkFg : NexoColors.lightFg;
    final fgMuted = dark ? NexoColors.darkFgMuted : NexoColors.lightFgMuted;

    final members = context.read<MemberProvider>().members;
    final defaultMember = members.isNotEmpty ? members.first.name : '';

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _seeds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final (title, freq, icon) = _seeds[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(NexoRadius.sm),
            onTap: defaultMember.isEmpty
                ? null
                : () async {
                    await context.read<TaskProvider>().addTask(
                          title: title,
                          whoRemembers: defaultMember,
                          whoDecides: defaultMember,
                          whoExecutes: defaultMember,
                          effort: 1,
                          frequency: freq,
                          days: const [],
                        );
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      AppToast.show(ctx, 'Adicionada: $title', kind: AppToastKind.success);
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: NexoColors.indigo.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(NexoRadius.sm),
                    ),
                    child: Icon(icon, color: NexoColors.indigo, size: 18),
                  ),
                  const SizedBox(width: NexoSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.display(size: NexoText.base, weight: FontWeight.w600, color: fg),
                        ),
                        Text(
                          freq,
                          style: TextStyle(fontSize: NexoText.xs, color: fgMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.plus, color: fgMuted, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
