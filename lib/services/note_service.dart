import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

/// Handles all Firestore CRUD operations for notes.
/// Keeping this logic separate from the UI makes it easier to test
/// and easier to swap out the backend later if needed.
class NoteService {
  final CollectionReference _notesRef =
      FirebaseFirestore.instance.collection('notes');

  /// CREATE - Add a new note to Firestore.
  Future<void> addNote(Note note) async {
    await _notesRef.add(note.toMap());
  }

  /// READ - Stream of all notes, most recently updated first.
  Stream<List<Note>> getNotes() {
    return _notesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// UPDATE - Update an existing note by its document id.
  Future<void> updateNote(Note note) async {
    if (note.id == null) {
      throw ArgumentError('Cannot update a note without an id');
    }
    await _notesRef.doc(note.id).update(note.toMap(isUpdate: true));
  }

  /// DELETE - Remove a note by its document id.
  Future<void> deleteNote(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }
}
