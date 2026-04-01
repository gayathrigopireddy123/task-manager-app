import 'package:flutter/material.dart';

enum TaskStatus { todo, inProgress, done }

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo: return 'To-Do';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.done: return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo: return Colors.orange;
      case TaskStatus.inProgress: return Colors.blue;
      case TaskStatus.done: return Colors.green;
    }
  }
}

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  TaskStatus status;
  String? blockedById;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.todo,
    this.blockedById,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'status': status.index,
    'blockedById': blockedById,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    dueDate: DateTime.parse(map['dueDate']),
    status: TaskStatus.values[map['status']],
    blockedById: map['blockedById'],
  );

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedById,
    bool clearBlockedBy = false,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    blockedById: clearBlockedBy ? null : (blockedById ?? this.blockedById),
  );
}