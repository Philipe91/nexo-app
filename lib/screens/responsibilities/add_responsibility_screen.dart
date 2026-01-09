import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../models/task_model.dart'; // Importante

class AddResponsibilityScreen extends StatefulWidget {
  final Task? taskToEdit; // Se vier preenchido, é modo EDIÇÃO

  const AddResponsibilityScreen({super.key, this.taskToEdit});

  @override
  State<AddResponsibilityScreen> createState() => _AddResponsibilityScreenState();
}

class _AddResponsibilityScreenState extends State<AddResponsibilityScreen> {
  final _formKey = GlobalKey<FormState>();

  String title = "";
  String? quemLembra;
  String? quemDecide;
  String? quemExecuta;
  String frequencia = "Semanal";
  int esforco = 1;

  final List<String> frequencias = ["Diário", "Semanal", "Mensal", "Eventual"];

  @override
  void initState() {
    super.initState();
    // Inicializa campos
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final members = context.read<MemberProvider>().members.map((m) => m.name).toList();
       
       if (members.isNotEmpty) {
         setState(() {
           if (widget.taskToEdit != null) {
             // --- MODO EDIÇÃO: CARREGA DADOS ---
             final t = widget.taskToEdit!;
             title = t.title;
             // Verifica se o membro ainda existe, senão pega o primeiro
             quemLembra = members.contains(t.whoRemembers) ? t.whoRemembers : members.first;
             quemDecide = members.contains(t.whoDecides) ? t.whoDecides : members.first;
             quemExecuta = members.contains(t.whoExecutes) ? t.whoExecutes : members.first;
             esforco = t.effort;
             frequencia = t.frequency;
           } else {
             // --- MODO CRIAÇÃO: PADRÕES ---
             quemLembra = members.first;
             quemDecide = members.length > 1 ? members[1] : members.first;
             quemExecuta = members.first;
           }
         });
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
            body: const Center(child: Text("Adicione membros primeiro."))
        );
    }
    
    // Fallback de segurança
    quemLembra ??= memberNames.first;
    quemDecide ??= memberNames.first;
    quemExecuta ??= memberNames.first;

    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          isEditing ? "Editar Tarefa" : "Nova Responsabilidade", 
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
        ),
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
            // TITULO (Inicializa o valor se for edição)
            TextFormField(
              initialValue: isEditing ? widget.taskToEdit!.title : null,
              decoration: InputDecoration(
                hintText: "Ex: Pagar Luz...",
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Icon(Icons.edit_note, color: theme.colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Dê um nome.' : null,
              onChanged: (value) => title = value,
            ),
            
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, 
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdownRow(theme, "Quem Lembra?", Icons.psychology, const Color(0xFF9C27B0), quemLembra!, memberNames, (val) => setState(() => quemLembra = val!)),
                  Divider(height: 24),
                  _buildDropdownRow(theme, "Quem Decide?", Icons.balance, const Color(0xFF2196F3), quemDecide!, memberNames, (val) => setState(() => quemDecide = val!)),
                  Divider(height: 24),
                  _buildDropdownRow(theme, "Quem Executa?", Icons.fitness_center, const Color(0xFFFF5722), quemExecuta!, memberNames, (val) => setState(() => quemExecuta = val!)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: frequencia,
                    decoration: InputDecoration(filled: true, fillColor: theme.colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: frequencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => frequencia = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: esforco,
                    decoration: InputDecoration(filled: true, fillColor: theme.colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: [
                      DropdownMenuItem(value: 1, child: Row(children: const [Icon(Icons.sentiment_satisfied_alt, color: Colors.green), SizedBox(width: 8), Text("Leve")])),
                      DropdownMenuItem(value: 2, child: Row(children: const [Icon(Icons.sentiment_neutral, color: Colors.orange), SizedBox(width: 8), Text("Médio")])),
                      DropdownMenuItem(value: 3, child: Row(children: const [Icon(Icons.whatshot, color: Colors.red), SizedBox(width: 8), Text("Pesado")])),
                    ],
                    onChanged: (val) => setState(() => esforco = val!),
                  ),
                ),
              ],
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

  Widget _buildDropdownRow(ThemeData theme, String label, IconData icon, Color color, String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    String safeValue = items.contains(currentValue) ? currentValue : items.first;
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        DropdownButton<String>(
          value: safeValue,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)))).toList(),
          onChanged: onChanged,
          underline: Container(),
        )
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Se título não mudou no modo edição, mantém o antigo
      if (title.isEmpty && widget.taskToEdit != null) {
        title = widget.taskToEdit!.title;
      }

      if (widget.taskToEdit != null) {
        // --- ATUALIZAR ---
        final updatedTask = Task(
          id: widget.taskToEdit!.id, // Mantém o mesmo ID
          title: title,
          whoRemembers: quemLembra!,
          whoDecides: quemDecide!,
          whoExecutes: quemExecuta!,
          effort: esforco,
          frequency: frequencia,
          createdAt: widget.taskToEdit!.createdAt,
        );
        context.read<TaskProvider>().updateTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tarefa atualizada!")));
      } else {
        // --- CRIAR NOVO ---
        context.read<TaskProvider>().addTask(
          title: title,
          whoRemembers: quemLembra!,
          whoDecides: quemDecide!,
          whoExecutes: quemExecuta!,
          effort: esforco,
          frequency: frequencia,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tarefa criada!")));
      }
      context.pop();
    }
  }
}