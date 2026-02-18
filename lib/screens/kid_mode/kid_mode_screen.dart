import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/bank_provider.dart'; // <--- Import Missing
import '../../core/models/member_model.dart';
import '../../models/task_model.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/xp_progress_bar.dart';
import '../../core/widgets/level_up_dialog.dart';

class KidModeScreen extends StatefulWidget {
  const KidModeScreen({super.key});

  @override
  State<KidModeScreen> createState() => _KidModeScreenState();
}

class _KidModeScreenState extends State<KidModeScreen> {
  String? _selectedKidId; 
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTaskId; // ID da tarefa que está tocando áudio atualmente

  // Dias da semana para cabeçalho
  final List<String> weekDays = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];

  // Pega o dia de hoje (Ex: "Seg")
  String get _todayCode {
    final now = DateTime.now();
    final dayNum = now.weekday; // 1 = Seg
    if (dayNum >= 1 && dayNum <= 7) return weekDays[dayNum - 1];
    return "Seg";
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playingTaskId = null;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String path, String taskId) async {
    if (_playingTaskId == taskId) {
      await _audioPlayer.stop();
      setState(() => _playingTaskId = null);
    } else {
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() => _playingTaskId = taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = context.watch<MemberProvider>().members;
    final taskProvider = context.watch<TaskProvider>();

    // Recupera o objeto atualizado do membro selecionado
    Member? selectedKid;
    if (_selectedKidId != null) {
      try {
        selectedKid = members.firstWhere((m) => m.id == _selectedKidId);
      } catch (e) {
        _selectedKidId = null; // Membro removido?
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Fundo clarinho
      body: SafeArea(
        child: Column(
          children: [
            // --- Cabeçalho Divertido ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 32),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text(
                    "Modo Criança",
                    style: GoogleFonts.fredoka( 
                      fontSize: 28, 
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  // Botão do Banco
                  if (selectedKid != null)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: IconButton(
                        icon: const Text("🏦", style: TextStyle(fontSize: 24)),
                        tooltip: "Abrir Banco",
                        onPressed: () => context.push('/bank/${selectedKid!.id}'),
                      ),
                    ),
                  // Botão da Loja
                  if (selectedKid != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: IconButton(
                        icon: const Text("🎁", style: TextStyle(fontSize: 24)),
                        tooltip: "Abrir Loja",
                        onPressed: () => context.push('/rewards/${selectedKid!.id}'),
                      ),
                    )
                  else 
                    const SizedBox(width: 48), // Equilibra se não tiver kid
                ],
              ),
            ),

            // --- Seleção da Criança ---
            if (selectedKid == null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Quem é você?", 
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: members.map((member) {
                          // Tratamento de cor seguro
                          Color color;
                          try {
                            color = Color(int.parse(member.color));
                          } catch (e) {
                            color = Colors.blue;
                          }

                          return GestureDetector(
                            onTap: () => setState(() => _selectedKidId = member.id),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                                    ]
                                  ),
                                  child: Center(
                                    child: Text(
                                      member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                                const SizedBox(height: 12),
                                Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                // Relationship Label
                                if (member.relationship != 'Outro')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      member.relationship, 
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)
                                    ),
                                  ),

                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                )
              ] else ...[
                // --- Área de Tarefas da Criança ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(int.parse(selectedKid.color)),
                            child: Text(selectedKid.name[0], style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Oi, ${selectedKid.name}!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("Suas missões de hoje ($_todayCode):", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() => _selectedKidId = null),
                            child: const Text("Trocar"),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      // --- BARRA DE XP ---
                      XpProgressBar(
                        currentXp: selectedKid.xp,
                        level: selectedKid.level,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
  
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _buildKidTasks(taskProvider, selectedKid),
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    }
  
    List<Widget> _buildKidTasks(TaskProvider taskProvider, Member kid) {
      // Filtra tarefas que:
      // 1. O 'whoExecutes' é a criança selecionada
      // 2. A tarefa está marcada para o dia de hoje (contains _todayCode)
      final allMyTasks = taskProvider.tasks.where((t) => t.whoExecutes == kid.name).toList();
      final myTasksToday = allMyTasks.where((t) => t.days.contains(_todayCode)).toList();
  
      if (myTasksToday.isEmpty) {
        // Verifica se tem tarefas em outros dias
        if (allMyTasks.isNotEmpty) {
           return [
            const SizedBox(height: 50),
            const Icon(Icons.today, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text(
              "Nenhuma missão para hoje!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
             const SizedBox(height: 8),
             Text(
              "Mas você tem ${allMyTasks.length} missões agendadas para outros dias.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ];
        }
  
        return [
          const SizedBox(height: 50),
          const Icon(Icons.star_rounded, size: 100, color: Colors.amber),
          const SizedBox(height: 20),
          const Text(
            "Uau! Tudo livre!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
           const Text(
            "Peça para seus pais adicionarem missões para você.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ];
      }
  
      return myTasksToday.map((task) {
        // Verifica se já foi feita hoje
        final isDone = _isCompletedToday(task);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          color: Colors.white,
          opacity: 1.0,
          onTap: () async {
            // Ação de Completar
            final wasCompleted = await taskProvider.toggleTaskCompletion(task.id);
            
            if (wasCompleted) {
              // Calcula XP e Moedas
              final xpEarned = task.effort * 50;
              final coinsEarned = task.effort * 10; // 10 moedas por nível de esforço

              // Adiciona XP e Moedas no membro (LOCAL)
              final leveledUp = context.read<MemberProvider>().addXpAndCoins(kid.id, xpEarned, coinsEarned);

              // REGISTRA TRANSAÇÃO NO BANCO (FIRESTORE)
              context.read<BankProvider>().addTransaction(
                kid.id, 
                coinsEarned.toDouble(), 
                "Missão: ${task.title}", 
                "credit"
              );

              if (leveledUp) {
                // Mostra Dialog de Level Up
                showDialog(
                  context: context, 
                  builder: (_) => LevelUpDialog(newLevel: kid.level + 1)
                );
              } else {
                // Snack com recompensa
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.white),
                        const SizedBox(width: 8),
                        Text("Mandou bem! +$xpEarned XP  |  +$coinsEarned Moedas 💰"),
                      ],
                    ),
                    backgroundColor: Colors.amber[700],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Checkbox Gigante
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: isDone ? Colors.green : Colors.grey.shade400, width: 3),
                  ),
                  child: isDone 
                    ? const Icon(Icons.check, color: Colors.white, size: 32)
                    : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : Colors.black87
                        ),
                      ),
                      Text(
                        "${task.effort} Pontos de Energia (+${task.effort * 50} XP)",
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                      ),
                      if (task.audioPath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: InkWell(
                            onTap: () => _playAudio(task.audioPath!, task.id),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _playingTaskId == task.id ? Colors.amber[100] : Colors.blue[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _playingTaskId == task.id ? Colors.amber : Colors.blue.withOpacity(0.3)
                                )
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _playingTaskId == task.id ? Icons.stop_circle : Icons.play_circle, 
                                    size: 20, 
                                    color: _playingTaskId == task.id ? Colors.amber[800] : Colors.blue
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _playingTaskId == task.id ? "Parar áudio" : "Ouvir instrução",
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                      color: _playingTaskId == task.id ? Colors.amber[900] : Colors.blue[800]
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildPhotoSlot(task, true)), // Antes
                          const SizedBox(width: 8),
                          Expanded(child: _buildPhotoSlot(task, false)), // Depois
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDone) 
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 32)
                      .animate().scale(curve: Curves.elasticOut),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _takePhoto(Task task, bool isBefore) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    
    if (photo != null) {
      // Cria nova tarefa com o caminho da foto atualizado
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        effort: task.effort,
        frequency: task.frequency,
        whoRemembers: task.whoRemembers,
        whoDecides: task.whoDecides,
        whoExecutes: task.whoExecutes,
        createdAt: task.createdAt,
        days: task.days,
        lastCompletedDate: task.lastCompletedDate,
        notifyAtTime: task.notifyAtTime,
        notify1hBefore: task.notify1hBefore,
        notify1dBefore: task.notify1dBefore,
        scheduledTime: task.scheduledTime,
        // Atualiza campos de foto
        photoBefore: isBefore ? photo.path : task.photoBefore,
        photoAfter: !isBefore ? photo.path : task.photoAfter,
      );

      // Salva no Provider
      await context.read<TaskProvider>().updateTask(updatedTask);
      setState(() {}); // Recarrega UI
    }
  }

  Widget _buildPhotoSlot(Task task, bool isBefore) {
    final path = isBefore ? task.photoBefore : task.photoAfter;
    final hasPhoto = path != null && path.isNotEmpty;
    final label = isBefore ? "Antes" : "Depois";

    return InkWell(
      onTap: () => _takePhoto(task, isBefore),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          image: hasPhoto 
            ? DecorationImage(
                image: FileImage(File(path)), 
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken)
              )
            : null,
        ),
        child: hasPhoto 
          ? Center(child: Icon(Icons.check_circle, color: Colors.white, size: 24))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.grey, size: 20),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
      ),
    );
  }

  bool _isCompletedToday(Task task) {
    if (task.lastCompletedDate == null) return false;
    final now = DateTime.now();
    final last = task.lastCompletedDate!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }
}