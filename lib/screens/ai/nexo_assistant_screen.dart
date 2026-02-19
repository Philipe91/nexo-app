import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/assistant_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/shopping_provider.dart';
import '../../core/providers/bank_provider.dart'; 
import '../../core/providers/cycle_provider.dart'; // <--- Import Adicionado

class NexoAssistantScreen extends StatefulWidget {
  const NexoAssistantScreen({super.key});

  @override
  State<NexoAssistantScreen> createState() => _NexoAssistantScreenState();
}

class _NexoAssistantScreenState extends State<NexoAssistantScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger Proactive AI Check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssistantProvider>().checkForProactiveSuggestions(
        cycleProvider: context.read<CycleProvider>(),
        memberProvider: context.read<MemberProvider>(),
      );
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text;
    _textController.clear();

    // Envia para o Provider processar
    context.read<AssistantProvider>().processMessage(
      text,
      taskProvider: context.read<TaskProvider>(),
      memberProvider: context.read<MemberProvider>(),
      shoppingProvider: context.read<ShoppingProvider>(),
      bankProvider: context.read<BankProvider>(), // <--- Adicionado
    );

    // Scroll para o fim
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final assistantProvider = context.watch<AssistantProvider>();
    final messages = assistantProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nexo AI", style: GoogleFonts.fredoka(color: Colors.black87)),
                const Text("Assistente Inteligente", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.isUser;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0, duration: 300.ms),
                );
              },
            ),
          ),
          
          // --- ÁREA DE INPUT ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ]
            ),
            child: Row(
              children: [
                // Botão de Áudio (Futuro)
                IconButton(
                  icon: const Icon(Icons.mic_none_rounded, color: Colors.indigo),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Comando de voz em breve! 🎙️"))
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Digite um comando...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
