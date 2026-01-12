import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/cycle_provider.dart';
import '../../models/member_model.dart';
import '../../core/widgets/glass_card.dart';

class CycleSettingsScreen extends StatefulWidget {
  const CycleSettingsScreen({super.key});

  @override
  State<CycleSettingsScreen> createState() => _CycleSettingsScreenState();
}

class _CycleSettingsScreenState extends State<CycleSettingsScreen> {
  Member? _selectedMember;
  DateTime _lastPeriod = DateTime.now();
  double _cycleLength = 28;
  double _periodLength = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;

    // Se não tiver membros, avisa
    if (members.isEmpty) {
      return Scaffold(
        appBar: AppBar(), 
        body: const Center(child: Text("Adicione membros primeiro."))
      );
    }

    // Inicializa com o primeiro membro se null
    _selectedMember ??= members.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurar Bio-Ritmo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Acompanhe a energia da casa",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "O app vai sugerir dicas de empatia baseadas no ciclo menstrual.",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          
          const SizedBox(height: 32),

          // 1. SELECIONAR MEMBRO
          const Text("De quem é este ciclo?", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isSelected = _selectedMember?.id == member.id;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedMember = member),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        member.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // 2. DATA DA ÚLTIMA MENSTRUAÇÃO
          GlassCard(
            color: Colors.white,
            opacity: 1,
            child: ListTile(
              title: const Text("Última Menstruação (Início)"),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_lastPeriod)),
              trailing: const Icon(Icons.calendar_today, color: Colors.pinkAccent),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _lastPeriod,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _lastPeriod = picked);
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. SLIDERS
          Text("Duração do Ciclo: ${_cycleLength.toInt()} dias", style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _cycleLength,
            min: 21,
            max: 35,
            divisions: 14,
            activeColor: Colors.pinkAccent,
            onChanged: (val) => setState(() => _cycleLength = val),
          ),

          Text("Duração do Sangramento: ${_periodLength.toInt()} dias", style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _periodLength,
            min: 3,
            max: 10,
            divisions: 7,
            activeColor: Colors.redAccent,
            onChanged: (val) => setState(() => _periodLength = val),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              icon: const Icon(Icons.favorite),
              style: FilledButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () {
                context.read<CycleProvider>().setCycle(
                  memberId: _selectedMember!.id,
                  lastPeriod: _lastPeriod,
                  cycleLen: _cycleLength.toInt(),
                  periodLen: _periodLength.toInt(),
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ciclo salvo com sucesso!")));
                context.pop();
              },
              label: const Text("Salvar Ciclo"),
            ),
          )

        ],
      ),
    );
  }
}