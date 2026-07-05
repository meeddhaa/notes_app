import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../utils/note_colors.dart';
import '../utils/time_ago.dart';
import 'add_edit_note_screen.dart';

/// Displays all notes stored in Firestore.
/// Supports live search, viewing, navigating to edit, and swipe-to-delete
/// with an undo option.
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NoteService _noteService = NoteService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_query.trim().isEmpty) return notes;
    final q = _query.toLowerCase();
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.description.toLowerCase().contains(q))
        .toList();
  }

  Future<bool> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete note?'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              backgroundColor: Colors.red.shade50,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteWithUndo(Note note) async {
    if (note.id == null) return;
    await _noteService.deleteNote(note.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text('"${note.title}" deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _noteService.addNote(Note(
              title: note.title,
              description: note.description,
              color: note.color,
            ));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: SafeArea(
        child: StreamBuilder<List<Note>>(
          stream: _noteService.getNotes(),
          builder: (context, snapshot) {
            final allNotes = snapshot.data ?? [];
            final notes = _filterNotes(allNotes);

            return Column(
              children: [
                _buildHeader(allNotes.length),
                _buildSearchBar(),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildBody(snapshot, notes, allNotes.isEmpty),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
        ),
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Note', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Text(
              'My Notes',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D1B4E),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              count == 1 ? '1 note' : '$count notes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _query = val),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade400),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<Note>> snapshot,
    List<Note> notes,
    bool trulyEmpty,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error: ${snapshot.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      );
    }
    if (trulyEmpty) {
      return _buildEmptyState();
    }
    if (notes.isEmpty) {
      return Center(
        child: Text(
          'No notes match "$_query"',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _NoteCard(
          note: note,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
          ),
          onDismiss: () => _confirmDelete(note),
          onDismissed: () => _deleteWithUndo(note),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.sticky_note_2_outlined,
                  size: 44, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D1B4E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "New Note" to write down\nyour first idea.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single note card with a colored accent stripe, swipe-to-delete,
/// and a relative last-updated timestamp.
class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Future<bool> Function() onDismiss;
  final VoidCallback onDismissed;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDismiss,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = hexToColor(note.color);
    final accentColor = hexToAccentColor(note.color);
    final updatedAt = note.updatedAt?.toDate();

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDismiss(),
      onDismissed: (_) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.55),
                borderRadius: BorderRadius.circular(18),
                border: Border(
                  left: BorderSide(color: accentColor, width: 4),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF2D1B4E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),
                        if (updatedAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            timeAgo(updatedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}