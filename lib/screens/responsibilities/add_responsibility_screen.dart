import 'package:nexo/core/models/member_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/member_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../models/task_model.dart';

class AddResponsibilityScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddResponsibilityScreen({super.key, this.taskToEdit});

  @override
  State<AddResponsibilityScreen> createState() =>
      _AddResponsibilityScreenState();
}

class _AddResponsibilityScreenState extends State<AddResponsibilityScreen> {
  final _formKey = GlobalKey<FormState>();

  String title = "";
  String? quemLembra;
  String? quemDecide;
  String? quemExecuta;
  String frequencia = "Semanal";
  int esforco = 1;
  List<String> selectedDays = []; // <--- Lista de dias selecionados

  // --- Novos Campos para Notificação ---
  bool _notifyAtTime = false;
  TimeOfDay? _selectedTime;

  // --- Campos de Áudio ---
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordedPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  final List<String> frequencias = ["Diário", "Semanal", "Mensal", "Eventual"];
  // Códigos dos dias para salvar no banco
  final List<String> weekDays = [
    "Seg",
    "Ter",
    "Qua",
    "Qui",
    "Sex",
    "Sáb",
    "Dom"
  ];

  @override
  void initState() {
    super.initState();
    
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => _isPlaying = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final members =
          context.read<MemberProvider>().members.map((m) => m.name).toList();

      if (members.isNotEmpty) {
        setState(() {
          if (widget.taskToEdit != null) {
            final t = widget.taskToEdit!;
            title = t.title;
            quemLembra = members.contains(t.whoRemembers)
                ? t.whoRemembers
                : members.first;
            quemDecide =
                members.contains(t.whoDecides) ? t.whoDecides : members.first;
            quemExecuta =
                members.contains(t.whoExecutes) ? t.whoExecutes : members.first;
            esforco = t.effort;
            frequencia = t.frequency;
            selectedDays = List.from(t.days); // Carrega os dias salvos
            
            // Carregar Notificação
            _notifyAtTime = t.notifyAtTime;
            if (t.scheduledTime != null) {
              _selectedTime = TimeOfDay.fromDateTime(t.scheduledTime!);
            }
            
            // Carregar Áudio
            _recordedPath = t.audioPath;
          } else {
            quemLembra = members.first;
            quemDecide = members.length > 1 ? members[1] : members.first;
            quemExecuta = members.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/audio_${const Uuid().v4()}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao gravar: $e")));
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordedPath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_recordedPath != null) {
      await _audioPlayer.play(DeviceFileSource(_recordedPath!));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  Future<void> _deleteRecording() async {
    await _audioPlayer.stop();
    setState(() {
      _recordedPath = null;
      _isPlaying = false;
    });
  }

  // Helper para alternar dias
  void _toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberObjects = context.watch<MemberProvider>().members;
    final memberNames = memberObjects.map((m) => m.name).toList();

    if (memberNames.isEmpty) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text("Adicione membros primeiro.")));
    }

    quemLembra ??= memberNames.first;
    quemDecide ??= memberNames.first;
    quemExecuta ??= memberNames.first;
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(isEditing ? "Editar Tarefa" : "Nova Responsabilidade",
            style: TextStyle(
                color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              initialValue: isEditing ? widget.taskToEdit!.title : null,
              decoration: InputDecoration(
                hintText: "Ex: Pagar Luz...",
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon:
                    Icon(Icons.edit_note, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Dê um nome.' : null,
              onChanged: (value) => title = value,
            ),

            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdownRow(
                      theme,
                      "Quem Lembra?",
                      Icons.psychology,
                      const Color(0xFF9C27B0),
                      quemLembra!,
                      memberObjects, // Passa a lista de objetos Member
                      (val) => setState(() => quemLembra = val!)),
                  const Divider(height: 24),
                  _buildDropdownRow(
                      theme,
                      "Quem Decide?",
                      Icons.balance,
                      const Color(0xFF2196F3),
                      quemDecide!,
                      memberObjects,
                      (val) => setState(() => quemDecide = val!)),
                  const Divider(height: 24),
                  _buildDropdownRow(
                      theme,
                      "Quem Executa?",
                      Icons.fitness_center,
                      const Color(0xFFFF5722),
                      quemExecuta!,
                      memberObjects,
                      (val) => setState(() => quemExecuta = val!)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Frequência e Esforço
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: frequencia,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none)),
                    items: frequencias
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) => setState(() => frequencia = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: esforco,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none)),
                    items: const [
                      DropdownMenuItem(
                          value: 1,
                          child: Row(children: [
                            Icon(Icons.sentiment_satisfied_alt,
                                color: Colors.green),
                            SizedBox(width: 8),
                            Text("Leve")
                          ])),
                      DropdownMenuItem(
                          value: 2,
                          child: Row(children: [
                            Icon(Icons.sentiment_neutral, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Médio")
                          ])),
                      DropdownMenuItem(
                          value: 3,
                          child: Row(children: [
                            Icon(Icons.whatshot, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Pesado")
                          ])),
                    ],
                    onChanged: (val) => setState(() => esforco = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SELEÇÃO DE DIAS ---
            const Text("Quais dias isso acontece?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weekDays.map((day) {
                final isSelected = selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (_) => _toggleDay(day),
                  backgroundColor: Colors.white,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300)),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            const Divider(),

            // --- NOTIFICAÇÕES (NOVA UI) ---
            SwitchListTile(
              title: const Text("Notificar no horário?", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Receba um lembrete no celular"),
              value: _notifyAtTime,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) => setState(() => _notifyAtTime = val),
            ),

            if (_notifyAtTime)
              ListTile(
                title: Text(
                  _selectedTime?.format(context) ?? "Escolher horário",
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                leading: Icon(Icons.alarm, color: theme.colorScheme.primary),
                tileColor: theme.colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context, 
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),

            const SizedBox(height: 32),

            // --- ÁUDIO ---
            _buildAudioSection(theme),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saveTask,
                child: Text(isEditing ? "SALVAR ALTERAÇÕES" : "CRIAR TAREFA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(
      ThemeData theme,
      String label,
      IconData icon,
      Color color,
      String currentValue,
      List<Member> members,
      ValueChanged<String?> onChanged) {
    
    // Encontra o membro atual ou usa o primeiro
    String safeValue = members.any((m) => m.name == currentValue) 
        ? currentValue 
        : (members.isNotEmpty ? members.first.name : "");

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold))),
        DropdownButton<String>(
          value: safeValue,
          items: members.map((m) {
            final displayName = m.relationship != 'Outro' && m.relationship.isNotEmpty
                ? "${m.name} (${m.relationship})" 
                : m.name;
            
            return DropdownMenuItem(
              value: m.name, // O valor salvo continua sendo o Nome (para compatibilidade com TaskModel)
              child: Text(displayName,
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold
                  )
              ),
            );
          }).toList(),
          onChanged: onChanged,
          underline: Container(),
        )
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (title.isEmpty && widget.taskToEdit != null) {
        title = widget.taskToEdit!.title;
      }

      // Preparar Data Agendada
      DateTime? scheduledDateTime;
      if (_notifyAtTime && _selectedTime != null) {
        final now = DateTime.now();
        scheduledDateTime = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
        // Se já passou hoje, agenda para agorinha ou amanhã? 
        // Por simplicidade, assumimos a data e hora compostas. 
        // O Service vai tentar agendar. Se for passado, dispara na hora ou falha dependendo da config.
        if (scheduledDateTime.isBefore(now)) {
           scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
        }
      }

      if (widget.taskToEdit != null) {
        final updatedTask = Task(
          id: widget.taskToEdit!.id,
          title: title,
          whoRemembers: quemLembra!,
          whoDecides: quemDecide!,
          whoExecutes: quemExecuta!,
          effort: esforco,
          frequency: frequencia,
          days: selectedDays, // <--- SALVA DIAS
          createdAt: widget.taskToEdit!.createdAt,
          // Novos Campos
          notifyAtTime: _notifyAtTime,
          scheduledTime: scheduledDateTime,
          audioPath: _recordedPath,
          photoBefore: widget.taskToEdit?.photoBefore,
          photoAfter: widget.taskToEdit?.photoAfter,
        );
        context.read<TaskProvider>().updateTask(updatedTask);
      } else {
        context.read<TaskProvider>().addTask(
              title: title,
              whoRemembers: quemLembra!,
              whoDecides: quemDecide!,
              whoExecutes: quemExecuta!,
              effort: esforco,
              frequency: frequencia,
              days: selectedDays, // <--- SALVA DIAS
              // Novos Campos
              notifyAtTime: _notifyAtTime,
              scheduledTime: scheduledDateTime,
              audioPath: _recordedPath,
            );
      }
      context.pop();
    }
  }

  Widget _buildAudioSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text("Instrução de Voz (Opcional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: _isRecording
              ? Column(
                  children: [
                    const Text("Gravando...", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 500.ms)
                        .then()
                        .fadeOut(duration: 500.ms),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      onPressed: _stopRecording,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.stop),
                    ),
                  ],
                )
              : _recordedPath == null
                ? ElevatedButton.icon(
                    onPressed: _startRecording, 
                    icon: const Icon(Icons.fiber_manual_record, color: Colors.white), 
                    label: const Text("Gravar Instrução"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, color: Colors.white),
                        onPressed: _isPlaying ? _stopPlayback : _playRecording,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteRecording,
                        tooltip: "Apagar Áudio",
                      ),
                    ],
                  ),
          ),
          if (_recordedPath != null)
             Center(child: Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: Text("Áudio gravado!", style: TextStyle(color: Colors.green[700], fontSize: 12)),
             ))
        ],
      ),
    );
  }
}
