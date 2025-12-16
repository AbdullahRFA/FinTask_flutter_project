import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime date;        // Created Date
  final DateTime lastEdited;  // Modified Date
  final int colorValue;       // Color integer

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.lastEdited,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'date': Timestamp.fromDate(date),
    'lastEdited': Timestamp.fromDate(lastEdited),
    'colorValue': colorValue,
  };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    date: (map['date'] as Timestamp).toDate(),
    lastEdited: (map['lastEdited'] as Timestamp).toDate(),
    colorValue: map['colorValue'] ?? 0xFFFFFFFF, // Default White
  );
}