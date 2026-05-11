import '../utils/date_format.dart';

enum Category {
  penting,
  biasa;

  String toDb() => name;

  static Category fromDb(String value) {
    switch (value) {
      case 'penting':
        return Category.penting;
      case 'biasa':
        return Category.biasa;
      default:
        throw ArgumentError('Kategori tidak dikenal: $value');
    }
  }

  String get label => this == Category.penting ? 'Penting' : 'Biasa';
}

class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final Category category;
  final bool isDone;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.category,
    required this.isDone,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'title': title,
      'description': description,
      'due_date': isoDate(dueDate),
      'category': category.toDb(),
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Task.fromMap(Map<String, Object?> m) {
    return Task(
      id: m['id'] as int?,
      title: m['title'] as String,
      description: m['description'] as String?,
      dueDate: parseIsoDate(m['due_date'] as String),
      category: Category.fromDb(m['category'] as String),
      isDone: (m['is_done'] as int) == 1,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Category? category,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
