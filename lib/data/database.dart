import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton koneksi SQLite untuk aplikasi.
///
/// Pakai pola lazy-init: koneksi dibuka saat [database] pertama kali diakses,
/// kemudian dipakai bersama seluruh aplikasi. [setTestDatabase] disediakan
/// sebagai injection point untuk testing dengan in-memory DB.
class AppDatabase {
  AppDatabase._();

  /// Instance singleton.
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  /// Akses lazy ke koneksi DB. Buka file kalau belum dibuka.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'agenda_nusantara.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
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
        await db.execute('CREATE INDEX idx_tasks_category ON tasks(category)');
        await db.execute('CREATE INDEX idx_tasks_is_done ON tasks(is_done)');
      },
    );
  }

  /// Inject [db] sebagai koneksi (untuk testing dengan in-memory DB).
  void setTestDatabase(Database db) {
    _db = db;
  }

  /// Tutup koneksi DB (cleanup di akhir test atau saat aplikasi dimatikan).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
