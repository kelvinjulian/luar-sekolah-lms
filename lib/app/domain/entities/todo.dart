// lib/app/domain/entities/todo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String? id;
  final String text;
  final bool completed;
  final DateTime? scheduledTime; // Field Baru: Deadline/Jadwal

  Todo({
    this.id,
    required this.text,
    required this.completed,
    this.scheduledTime,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    // Helper: Konversi data waktu dari berbagai format (Timestamp/String/Null)
    DateTime? parseTime(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate(); // Dari Firestore
      if (val is String) return DateTime.tryParse(val); // Dari JSON biasa
      return null;
    }

    return Todo(
      // Handle id atau _id (untuk kompatibilitas)
      id: json['id'] as String? ?? json['_id'] as String?,
      text: json['text'] as String,
      completed: json['completed'] as bool? ?? false,
      scheduledTime: parseTime(json['scheduledTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'completed': completed,
      // Simpan sebagai Timestamp ke Firestore agar mudah di-query/sort
      'scheduledTime': scheduledTime != null
          ? Timestamp.fromDate(scheduledTime!)
          : null,
    };
  }

  Todo copyWith({
    String? id,
    String? text,
    bool? completed,
    DateTime? scheduledTime,
  }) => Todo(
    id: id ?? this.id,
    text: text ?? this.text,
    completed: completed ?? this.completed,
    scheduledTime: scheduledTime ?? this.scheduledTime,
  );
}
