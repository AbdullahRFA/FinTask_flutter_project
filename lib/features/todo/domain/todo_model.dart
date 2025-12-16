import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TodoPriority { low, medium, high }

class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime date;      // Creation Date
  final DateTime? dueDate;  // Deadline
  final TodoPriority priority;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.date,
    this.dueDate,
    this.priority = TodoPriority.medium,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'date': Timestamp.fromDate(date),
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'priority': priority.index, // Store as int (0, 1, 2)
  };

  factory TodoModel.fromMap(Map<String, dynamic> map) => TodoModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    isCompleted: map['isCompleted'] ?? false,
    date: (map['date'] as Timestamp).toDate(),
    dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
    priority: TodoPriority.values[map['priority'] ?? 1], // Default Medium
  );

  // Helper for Colors
  Color get priorityColor {
    switch (priority) {
      case TodoPriority.high: return Colors.red;
      case TodoPriority.medium: return Colors.orange;
      case TodoPriority.low: return Colors.green;
    }
  }
}