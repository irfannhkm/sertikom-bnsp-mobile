import '../models/task.dart';
import '../utils/date_format.dart';
import 'database.dart';
import 'storage_interface.dart';

class TaskRepository implements StorageInterface<Task> {
  @override
  Future<int> insert(Task task) async {
    final db = await AppDatabase.instance.database;
    return db.insert('tasks', task.toMap());
  }

  @override
  Future<List<Task>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'tasks',
      orderBy: 'is_done ASC, due_date ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<void> toggleDone(int id, bool done) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'tasks',
      {'is_done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDone() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM tasks WHERE is_done = 1',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> countUndone() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM tasks WHERE is_done = 0',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<List<int>> weeklyDoneCounts(DateTime reference) async {
    final db = await AppDatabase.instance.database;
    final monday = startOfWeekMonday(reference);
    final sundayEnd = endOfWeekSunday(reference);
    final rows = await db.rawQuery(
      '''
      SELECT DATE(created_at) AS d, COUNT(*) AS c
      FROM tasks
      WHERE is_done = 1
        AND created_at BETWEEN ? AND ?
      GROUP BY DATE(created_at)
      ''',
      [monday.toIso8601String(), sundayEnd.toIso8601String()],
    );
    final counts = List<int>.filled(7, 0);
    for (final row in rows) {
      final d = parseIsoDate(row['d'] as String);
      final idx = d.difference(monday).inDays;
      if (idx >= 0 && idx < 7) {
        counts[idx] = row['c'] as int;
      }
    }
    return counts;
  }
}
