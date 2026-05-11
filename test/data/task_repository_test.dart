import 'package:agenda_nusantara/data/database.dart';
import 'package:agenda_nusantara/data/task_repository.dart';
import 'package:agenda_nusantara/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late TaskRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (d, _) async {
          await d.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              due_date TEXT NOT NULL,
              category TEXT NOT NULL CHECK (category IN ('penting','biasa')),
              is_done INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    AppDatabase.instance.setTestDatabase(db);
    repo = TaskRepository();
  });

  tearDown(() async {
    await db.close();
  });

  Task makeTask({
    String title = 'Test',
    Category cat = Category.biasa,
    bool done = false,
    DateTime? created,
  }) {
    return Task(
      title: title,
      description: null,
      dueDate: DateTime(2026, 5, 12),
      category: cat,
      isDone: done,
      createdAt: created ?? DateTime(2026, 5, 8),
    );
  }

  test('insert returns generated id', () async {
    final id = await repo.insert(makeTask());
    expect(id, greaterThan(0));
  });

  test(
    'getAll returns inserted rows ordered: undone first, then due_date asc',
    () async {
      await repo.insert(
        Task(
          title: 'B done',
          dueDate: DateTime(2026, 5, 10),
          category: Category.biasa,
          isDone: true,
          createdAt: DateTime(2026, 5, 8),
        ),
      );
      await repo.insert(
        Task(
          title: 'A undone late',
          dueDate: DateTime(2026, 5, 20),
          category: Category.penting,
          isDone: false,
          createdAt: DateTime(2026, 5, 8),
        ),
      );
      await repo.insert(
        Task(
          title: 'C undone early',
          dueDate: DateTime(2026, 5, 9),
          category: Category.biasa,
          isDone: false,
          createdAt: DateTime(2026, 5, 8),
        ),
      );
      final list = await repo.getAll();
      expect(list.map((t) => t.title).toList(), [
        'C undone early',
        'A undone late',
        'B done',
      ]);
    },
  );

  test('toggleDone flips is_done', () async {
    final id = await repo.insert(makeTask(done: false));
    await repo.toggleDone(id, true);
    final list = await repo.getAll();
    expect(list.first.isDone, true);
    await repo.toggleDone(id, false);
    final list2 = await repo.getAll();
    expect(list2.first.isDone, false);
  });

  test('countDone / countUndone', () async {
    await repo.insert(makeTask(done: true));
    await repo.insert(makeTask(done: true));
    await repo.insert(makeTask(done: false));
    expect(await repo.countDone(), 2);
    expect(await repo.countUndone(), 1);
  });

  test('weeklyDoneCounts returns 7 buckets keyed Mon..Sun', () async {
    Future<void> insertOn(DateTime when, bool done) => repo.insert(
      Task(
        title: 't',
        dueDate: when,
        category: Category.biasa,
        isDone: done,
        createdAt: when,
      ),
    );
    await insertOn(DateTime(2026, 5, 4, 9), true);
    await insertOn(DateTime(2026, 5, 4, 10), true);
    await insertOn(DateTime(2026, 5, 6, 9), true);
    await insertOn(DateTime(2026, 5, 6, 10), false);
    await insertOn(DateTime(2026, 5, 8, 9), true);

    final counts = await repo.weeklyDoneCounts(DateTime(2026, 5, 8));
    expect(counts.length, 7);
    expect(counts[0], 2);
    expect(counts[1], 0);
    expect(counts[2], 1);
    expect(counts[3], 0);
    expect(counts[4], 1);
    expect(counts[5], 0);
    expect(counts[6], 0);
  });
}
