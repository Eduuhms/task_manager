import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String priority;
  final DateTime? dueDate;
  final String? categoryId;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.priority = 'medium',
    this.dueDate,
    this.categoryId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      completed: map['completed'] == 1,
      priority: map['priority'] ?? 'medium',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      categoryId: map['categoryId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Task copyWith({
    String? title,
    String? description,
    bool? completed,
    String? priority,
    DateTime? dueDate,
    String? categoryId,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
    );
  }
}