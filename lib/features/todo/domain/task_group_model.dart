import 'package:cloud_firestore/cloud_firestore.dart';

class TaskGroupModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt; // When the folder was created (System time)
  final DateTime deadline;  // The date picked by the user

  TaskGroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': Timestamp.fromDate(deadline),
    };
  }

  factory TaskGroupModel.fromMap(Map<String, dynamic> map) {
    // Handle migration: If 'deadline' doesn't exist, use 'createdAt'
    final created = (map['createdAt'] as Timestamp).toDate();
    final deadlineTimestamp = map['deadline'] as Timestamp?;

    return TaskGroupModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: created,
      deadline: deadlineTimestamp != null ? deadlineTimestamp.toDate() : created,
    );
  }
}