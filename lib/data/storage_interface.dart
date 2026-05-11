/// Kontrak generik untuk repository CRUD.
///
/// Diimplementasikan oleh class konkret (mis. [TaskRepository]) supaya
/// signature operasi storage konsisten dan mudah di-swap (SQLite, REST API,
/// in-memory, dll.) tanpa mengubah lapisan pemanggil.
abstract class StorageInterface<T> {
  /// Sisipkan satu item baru. Mengembalikan id auto-generate.
  Future<int> insert(T item);

  /// Ambil semua item.
  Future<List<T>> getAll();

  /// Hapus item berdasarkan id.
  Future<void> delete(int id);
}
