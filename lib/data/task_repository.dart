import '../models/task.dart';
import '../utils/date_format.dart';
import 'database.dart';
import 'storage_interface.dart';

/// Akses data tugas (tabel `tasks` di SQLite).
///
/// Mengimplementasikan [StorageInterface] untuk operasi CRUD generik plus
/// method spesifik domain seperti [toggleDone], [countDone], dan
/// [weeklyDoneCounts] untuk kebutuhan statistik di HomePage.
class TaskRepository implements StorageInterface<Task> {
  /// Sisipkan satu tugas. Mengembalikan id baru hasil AUTOINCREMENT.
  @override
  Future<int> insert(Task task) async {
    final db = await AppDatabase.instance.database;
    return db.insert('tasks', task.toMap());
  }

  /// Ambil semua tugas, diurutkan belum-selesai dulu lalu by tanggal terdekat.
  @override
  Future<List<Task>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'tasks',
      orderBy: 'is_done ASC, due_date ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  /// Set status selesai tugas dengan [id]. [done] true=selesai, false=belum.
  Future<void> toggleDone(int id, bool done) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'tasks',
      {'is_done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hapus tugas berdasarkan [id]. Tidak ada efek kalau id tidak ada.
  @override
  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Hitung total tugas yang sudah selesai (is_done = 1).
  Future<int> countDone() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM tasks WHERE is_done = 1',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  /// Hitung total tugas yang belum selesai (is_done = 0).
  Future<int> countUndone() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM tasks WHERE is_done = 0',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  /// Jumlah tugas selesai per hari dalam minggu yang memuat [reference].
  ///
  /// Return array 7 elemen: index 0=Senin sampai 6=Minggu.
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
