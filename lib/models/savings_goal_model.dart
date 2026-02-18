import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String kidId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final int iconCodePoint; // Para salvar o IconData
  final String? colorHex;

  SavingsGoal({
    required this.id,
    required this.kidId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.iconCodePoint,
    this.colorHex,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kidId': kidId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'iconCodePoint': iconCodePoint,
      'colorHex': colorHex,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] ?? '',
      kidId: map['kidId'] ?? '',
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      iconCodePoint: map['iconCodePoint'] ?? Icons.savings.codePoint,
      colorHex: map['colorHex'],
    );
  }
  
  SavingsGoal copyWith({
    double? currentAmount,
  }) {
    return SavingsGoal(
      id: id,
      kidId: kidId,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
    );
  }
}
