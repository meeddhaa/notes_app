import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single Note stored in Firestore.
class Note {
  final String? id;
  final String title;
  final String description;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert a Firestore document snapshot into a Note object.
  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  /// Convert a Note object into a Map for writing to Firestore.
  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'title': title,
      'description': description,
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
