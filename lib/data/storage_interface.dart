abstract class StorageInterface<T> {
  Future<int> insert(T item);

  Future<List<T>> getAll();

  Future<void> delete(int id);
}
