import 'package:agenda_nusantara/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category enum', () {
    test('toDb produces lowercase Indonesian literal', () {
      expect(Category.penting.toDb(), 'penting');
      expect(Category.biasa.toDb(), 'biasa');
    });

    test('fromDb parses correctly', () {
      expect(Category.fromDb('penting'), Category.penting);
      expect(Category.fromDb('biasa'), Category.biasa);
    });

    test('fromDb throws on unknown literal', () {
      expect(() => Category.fromDb('lainnya'), throwsArgumentError);
    });
  });

  group('Task.toMap / fromMap', () {
    test('round trip preserves all fields', () {
      final t = Task(
        id: 7,
        title: 'Submit laporan',
        description: 'Final report',
        dueDate: DateTime(2026, 5, 12),
        category: Category.penting,
        isDone: true,
        createdAt: DateTime(2026, 5, 8, 10, 30),
      );
      final back = Task.fromMap(t.toMap()..['id'] = 7);
      expect(back.id, 7);
      expect(back.title, 'Submit laporan');
      expect(back.description, 'Final report');
      expect(back.dueDate, DateTime(2026, 5, 12));
      expect(back.category, Category.penting);
      expect(back.isDone, true);
      expect(back.createdAt, DateTime(2026, 5, 8, 10, 30));
    });

    test('toMap stores isDone as 0/1', () {
      final t = Task(
        title: 'a',
        dueDate: DateTime(2026, 1, 1),
        category: Category.biasa,
        isDone: false,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(t.toMap()['is_done'], 0);
    });

    test('toMap omits id when null', () {
      final t = Task(
        title: 'a',
        dueDate: DateTime(2026, 1, 1),
        category: Category.biasa,
        isDone: false,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(t.toMap().containsKey('id'), false);
    });
  });

  test('copyWith only changes specified fields', () {
    final t = Task(
      id: 1,
      title: 'a',
      dueDate: DateTime(2026, 1, 1),
      category: Category.biasa,
      isDone: false,
      createdAt: DateTime(2026, 1, 1),
    );
    final t2 = t.copyWith(isDone: true);
    expect(t2.id, 1);
    expect(t2.title, 'a');
    expect(t2.isDone, true);
  });
}
