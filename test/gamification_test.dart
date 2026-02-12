import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/providers/member_provider.dart';
import 'package:nexo/core/providers/task_provider.dart';
import 'package:nexo/core/models/member_model.dart';
import 'package:nexo/models/task_model.dart';

void main() {
  // Mock SharedPreferences
  SharedPreferences.setMockInitialValues({});

  group('Gamification Logic', () {
    late MemberProvider memberProvider;
    late TaskProvider taskProvider;

    setUp(() {
      memberProvider = MemberProvider();
      taskProvider = TaskProvider();
    });

    test('Add Member starts with 0 XP and Level 1', () {
      memberProvider.addMember('Teste Kid', '0xFF000000');
      final member = memberProvider.members.first;
      
      expect(member.name, 'Teste Kid');
      expect(member.xp, 0);
      expect(member.level, 1);
    });

    test('Adding 500 XP keeps Level 1', () {
      memberProvider.addMember('Teste Kid', '0xFF000000');
      final memberId = memberProvider.members.first.id;

      final leveledUp = memberProvider.addXp(memberId, 500);
      final member = memberProvider.members.first;

      expect(member.xp, 500);
      expect(member.level, 1);
      expect(leveledUp, false);
    });

    test('Adding 1000 XP triggers Level Up to 2', () {
      memberProvider.addMember('Teste Kid', '0xFF000000');
      final memberId = memberProvider.members.first.id;

      // 0 -> 1000 XP
      final leveledUp = memberProvider.addXp(memberId, 1000);
      final member = memberProvider.members.first;

      expect(member.xp, 1000);
      expect(member.level, 2); // 1 + (1000/1000) = 2
      expect(leveledUp, true);
    });

    test('Completing Task awards XP via logic simluation', () {
      // Setup Member
      memberProvider.addMember('Kid', '0xFF000000');
      final kid = memberProvider.members.first;

      // Setup Task
      taskProvider.addTask(
        title: 'Lavar Louça',
        whoRemembers: 'Mãe',
        whoDecides: 'Mãe',
        whoExecutes: 'Kid', // Mismo nome
        effort: 2, // 2 * 50 = 100 XP
        frequency: 'Diário',
        days: ['Seg'],
      );
      
      final task = taskProvider.tasks.first;

      // Simulate UI Logic: Toggle -> Check if True -> Add XP
      final completed = taskProvider.toggleTaskCompletion(task.id);
      expect(completed, true);

      if (completed) {
        final xpEarned = task.effort * 50;
        memberProvider.addXp(kid.id, xpEarned);
      }

      final updatedKid = memberProvider.members.first;
      expect(updatedKid.xp, 100); // 2 * 50
    });
  });
}
