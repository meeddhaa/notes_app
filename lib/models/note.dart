import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/note_colors.dart';

/// Represents a single Note stored in Firestore.
class Note {
  final String? id;
  final String title;
  final String description;
  final String color; // hex string, e.g. "#F3E8FF"
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.color = defaultNoteColor,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert a Firestore document snapshot into a Note object.
  /// Older documents created before the color feature existed simply
  /// won't have a 'color' field, so we fall back to the default pastel.
  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      color: data['color'] ?? defaultNoteColor,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  /// Convert a Note object into a Map for writing to Firestore.
  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'title': title,
      'description': description,
      'color': color,
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}