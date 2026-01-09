import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';

class AddResponsibilityScreen extends StatefulWidget {
  const AddResponsibilityScreen({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Acesso aos membros via Provider
       final members = context.read<MemberProvider>().members;
       if (members.isNotEmpty) {
         setState(() {
           // Inicializa com os nomes
           quemLembra = members.first.name;
           quemDecide = members.length > 1 ? members[1].name : members.first.name;
           quemExecuta = members.first.name;
         });
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Obtém a lista de membros do Provider
    final memberObjects = context.watch<MemberProvider>().members;
    // Transforma Objetos em Lista de Nomes (Strings) para o Dropdown
    final memberNames = memberObjects.map((m) => m.name).toList();

    if (memberNames.isEmpty) {
        return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Ops! Adicione membros na tela 'Membros' primeiro."))
        );
    }
    
    quemLembra ??= memberNames.first;
    quemDecide ??= memberNames.first;
    quemExecuta ??= memberNames.first;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("Nova Responsabilidade", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
            Text("O que precisa ser gerenciado?", 
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Ex: Agendar Pediatra, Pagar Luz...",
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Icon(Icons.edit_note, color: theme.colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, dê um nome.' : null,
              onChanged: (value) => title = value,
            ),
            
            const SizedBox(height: 32),

            Row(
              children: [
                Icon(Icons.psychology, color: const Color(0xFF9C27B0), size: 28),
                const SizedBox(width: 12),
                Text("Definição de Papéis", 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.onSurface
                  )),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdownRow(theme, "Quem Lembra?", "Carga Mental", Icons.psychology, const Color(0xFF9C27B0), quemLembra!, memberNames, (val) => setState(() => quemLembra = val!)),
                  Divider(color: Colors.grey.shade100, height: 24),
                  _buildDropdownRow(theme, "Quem Decide?", "Autoridade", Icons.balance, const Color(0xFF2196F3), quemDecide!, memberNames, (val) => setState(() => quemDecide = val!)),
                  Divider(color: Colors.grey.shade100, height: 24),
                  _buildDropdownRow(theme, "Quem Executa?", "Mão na Massa", Icons.fitness_center, const Color(0xFFFF5722), quemExecuta!, memberNames, (val) => setState(() => quemExecuta = val!)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Frequência", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: frequencia,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: theme.colorScheme.surface, 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: frequencias.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setState(() => frequencia = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Esforço", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: esforco,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: theme.colorScheme.surface, 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: [
                          _buildColorItem(1, "Leve", Icons.sentiment_satisfied_alt, Colors.green),
                          _buildColorItem(2, "Médio", Icons.sentiment_neutral, Colors.orange),
                          _buildColorItem(3, "Pesado", Icons.whatshot, Colors.red),
                        ],
                        onChanged: (val) => setState(() => esforco = val!),
                      ),
                    ],
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
                style: FilledButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("CRIAR RESPONSABILIDADE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<int> _buildColorItem(int value, String text, IconData icon, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(ThemeData theme, String label, String sublabel, IconData icon, Color iconColor, String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    String safeValue = items.contains(currentValue) ? currentValue : items.first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(sublabel, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<String>(
            value: safeValue,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
            items: items.map((role) {
              return DropdownMenuItem(
                value: role, 
                child: Text(role, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 14))
              );
            }).toList(),
            onChanged: onChanged,
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      context.read<TaskProvider>().addTask(
        title: title,
        whoRemembers: quemLembra!,
        whoDecides: quemDecide!,
        whoExecutes: quemExecuta!,
        effort: esforco,
        frequency: frequencia,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✨ $title adicionada!"), backgroundColor: Theme.of(context).colorScheme.primary, behavior: SnackBarBehavior.floating),
      );
      context.pop();
    }
  }
}