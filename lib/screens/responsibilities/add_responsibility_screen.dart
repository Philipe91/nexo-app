import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
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
          } else {
            quemLembra = members.first;
            quemDecide = members.length > 1 ? members[1] : members.first;
            quemExecuta = members.first;
          }
        });
      }
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
                      memberNames,
                      (val) => setState(() => quemLembra = val!)),
                  const Divider(height: 24),
                  _buildDropdownRow(
                      theme,
                      "Quem Decide?",
                      Icons.balance,
                      const Color(0xFF2196F3),
                      quemDecide!,
                      memberNames,
                      (val) => setState(() => quemDecide = val!)),
                  const Divider(height: 24),
                  _buildDropdownRow(
                      theme,
                      "Quem Executa?",
                      Icons.fitness_center,
                      const Color(0xFFFF5722),
                      quemExecuta!,
                      memberNames,
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

            // --- SELEÇÃO DE DIAS (NOVO COMPONENTE UI) ---
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
      List<String> items,
      ValueChanged<String?> onChanged) {
    String safeValue =
        items.contains(currentValue) ? currentValue : items.first;
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold))),
        DropdownButton<String>(
          value: safeValue,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold))))
              .toList(),
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
            );
      }
      context.pop();
    }
  }
}
