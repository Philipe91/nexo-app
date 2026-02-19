import 'package:flutter/material.dart';
import 'package:nexo/core/providers/task_provider.dart';
import 'package:nexo/core/providers/shopping_provider.dart'; 
import 'package:nexo/core/providers/member_provider.dart';
import 'package:nexo/core/providers/bank_provider.dart'; // <--- Import Adicionado
import 'package:uuid/uuid.dart';

class AssistantMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AssistantMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AssistantProvider extends ChangeNotifier {
  final List<AssistantMessage> _messages = [
    AssistantMessage(
      id: 'welcome',
      text: "Olá! Sou o cérebro da casa. 🧠\nPosso te ajudar a lembrar de coisas ou organizar tarefas. Tente dizer:\n\n'Lembrar o Papai de comprar leite amanhã'",
      isUser: false,
      timestamp: DateTime.now(),
    )
  ];

  List<AssistantMessage> get messages => _messages;

  // Referências para outros providers (serão injetados ou acessados via contexto na UI, 
  // mas aqui vamos receber funções de callback ou usar um Service Locator se o app crescer.
  // Por simplicidade, vamos processar o texto e retornar uma Action que a UI executa,
  // OU (melhor) passar os providers no método de processamento.
  
  Future<void> processMessage(
    String text, {
    required TaskProvider taskProvider,
    required MemberProvider memberProvider,
    required ShoppingProvider shoppingProvider,
    required BankProvider bankProvider, // <--- Adicionado
  }) async {
    // 1. Adiciona mensagem do usuário
    _addMessage(text, true);

    // 2. Simula "pensando"
    notifyListeners(); 
    await Future.delayed(const Duration(milliseconds: 800));

    // 3. Processa
    String response = "Desculpe, ainda estou aprendendo.";
    
    final lowerText = text.toLowerCase();

    // --- COMANDO: LEMBRAR / TAREFA ---
    if (lowerText.contains("lembrar") || lowerText.contains("agendar")) {
      response = await _handleTaskCreation(text, taskProvider, memberProvider);
    } 
    // --- COMANDO: COMPRAS ---
    else if (lowerText.contains("comprar") || 
             (lowerText.contains("adicionar") && lowerText.contains("lista")) ||
             (lowerText.contains("pôr") && lowerText.contains("lista"))) {
      response = await _handleShoppingCreation(text, shoppingProvider);
    }
    // --- COMANDO: FINANCEIRO (NOVO) ---
    else if (lowerText.contains("gastei") || lowerText.contains("pagou") || lowerText.contains("custou")) {
      response = await _handleTransactionCreation(text, bankProvider);
    }
    // --- COMANDO: DEBUG ---
    else if (lowerText.contains("quem mora aqui")) {
      final names = memberProvider.members.map((m) => m.name).join(", ");
      response = "Aqui moram: $names.";
    } else {
      response = "Não entendi bem. Tente 'Lembrar [alguém] de [algo]', 'Comprar [item]' ou 'Gastei [valor]'.";
    }

    // 4. Responde
    _addMessage(response, false);
  }

  void _addMessage(String text, bool isUser) {
    _messages.add(AssistantMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // --- LÓGICA DE COMPRAS ---
  Future<String> _handleShoppingCreation(String text, ShoppingProvider shoppingProvider) async {
    // Tenta extrair o item
    // Ex: "Comprar leite", "Adicionar ovos na lista"
    
    String? item;
    
    // Regex 1: "Comprar (.*)"
    // Regex 2: "Adicionar (.*) na lista"
    
    final regexBuy = RegExp(r"comprar\s+(.*)", caseSensitive: false);
    final regexAdd = RegExp(r"(?:adicionar|colocar|pôr)\s+(.*?)\s+(?:na|a|no)\s+(?:lista|mercado|carrinho)", caseSensitive: false);

    final matchAdd = regexAdd.firstMatch(text);
    if (matchAdd != null) {
      item = matchAdd.group(1);
    } else {
      final matchBuy = regexBuy.firstMatch(text);
      if (matchBuy != null) {
        item = matchBuy.group(1);
        // Remove "na lista" ou "no mercado" se tiver sobrado
        item = item?.replaceAll(RegExp(r"\s+(na|no)\s+(lista|mercado|carrinho).*"), "");
      }
    }

    if (item != null) {
      item = item!.trim();
      await shoppingProvider.addItem(item, "Nexo AI");
      return "Adicionei '$item' na lista de compras! 🛒";
    }

    return "Entendi que é para comprar algo, mas qual o item? Tente 'Comprar leite'.";
  }

  // --- LÓGICA DE FINANCEIRO (NOVO) ---
  Future<String> _handleTransactionCreation(String text, BankProvider bankProvider) async {
    // Tenta extrair o valor e a descrição
    // Ex: "Gastei 50 no mercado", "Custou 20 reais o sorvete"

    double? amount;
    String? description;

    // 1. Extrair Valor (regex de números simples)
    final regexAmount = RegExp(r"(\d+(?:[.,]\d{1,2})?)");
    final matchAmount = regexAmount.firstMatch(text);
    if (matchAmount != null) {
      String amountStr = matchAmount.group(1)!.replaceAll(',', '.');
      amount = double.tryParse(amountStr);
    }

    // 2. Extrair Descrição
    // Pega tudo depois de "no", "na", "com", "em"
    final regexDesc = RegExp(r"(?:no|na|com|em)\s+(.*)", caseSensitive: false);
    final matchDesc = regexDesc.firstMatch(text);
    if (matchDesc != null) {
      description = matchDesc.group(1);
    } else {
      // Tenta pegar o restante da frase removendo palavras chaves
       description = text.replaceAll(RegExp(r"(gastei|custou|pagou|reais|\d+|no|na|com|em)", caseSensitive: false), "").trim();
    }
    
    // Capitalize
    if (description != null && description.isNotEmpty) {
      description = description[0].toUpperCase() + description.substring(1);
    } else {
      description = "Despesa Diversa";
    }

    if (amount != null) {
      // Cria transação como 'family' (sem afetar saldo de membros)
      await bankProvider.addTransaction(
        'family', // ID especial
        amount, 
        description, 
        'debit'
      );
      return "Registrei uma despesa de R\$ ${amount.toStringAsFixed(2)} em '$description'. 💸";
    }

    return "Entendi que houve um gasto, mas não identifiquei o valor. Tente 'Gastei 50 no mercado'.";
  }

  // --- LÓGICA DE TAREFAS (Mantida) ---
  Future<String> _handleTaskCreation(
    String text, 
    TaskProvider taskProvider, 
    MemberProvider memberProvider
  ) async {
    // Tenta extrair: "Lembrar [QUEM] de [O QUE]"
    // Ex: "Lembrar o Pedro de tirar o lixo"
    
    String? who;
    String? what;

    // 1. Identificar Membro
    final members = memberProvider.members;
    for (var m in members) {
      if (text.toLowerCase().contains(m.name.toLowerCase())) {
        who = m.name;
        break;
      }
    }

    // Default se não achar ngm: "Eu" ou primeiro da lista
    who ??= members.isNotEmpty ? members.first.name : "Alguém";

    // 2. Identificar Tarefa (tudo depois de "de" ou "que")
    // Regex simples: "de (.*)"
    final regex = RegExp(r"\bde\b\s+(.*)", caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null) {
      what = match.group(1);
    } else {
      // Fallback: Pega tudo depois de "lembrar"
      final regex2 = RegExp(r"lembrar\s+(.*)", caseSensitive: false);
      final match2 = regex2.firstMatch(text);
      if (match2 != null) what = match2.group(1);
    }

    if (who != null && what != null) {
      // Limpeza básica
      what = what.replaceAll(RegExp(r"\bamanhã\b"), "").trim(); // Remove "amanhã" do título
      
      // Cria a tarefa
      await taskProvider.addTask(
        title: what, // Capitalize?
        whoRemembers: who, // O próprio?
        whoDecides: who,
        whoExecutes: who,
        effort: 1,
        frequency: "Eventual",
        days: ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"], // Disponível qq dia
        // Se tiver "amanhã No texto", poderia agendar. V2.
      );

      return "Combinado! Criei a tarefa for '$what' para o(a) $who.";
    }

    return "Entendi que é uma tarefa, mas não captei quem ou o quê. Tente: 'Lembrar o [Nome] de [Fazer algo]'.";
  }
}
