import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../utils/note_colors.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final NoteService _noteService = NoteService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedColor;

  bool _isSaving = false;
  int _descLength = 0;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
    _selectedColor = widget.note?.color ?? defaultNoteColor;
    _descLength = _descriptionController.text.length;
    _descriptionController.addListener(() {
      setState(() => _descLength = _descriptionController.text.length);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      if (_isEditing) {
        final updatedNote = Note(
          id: widget.note!.id,
          title: title,
          description: description,
          color: _selectedColor,
        );
        await _noteService.updateNote(updatedNote);
      } else {
        final newNote = Note(
          title: title,
          description: description,
          color: _selectedColor,
        );
        await _noteService.addNote(newNote);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text('Something went wrong: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = hexToAccentColor(_selectedColor);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7FF),
        elevation: 0,
        foregroundColor: const Color(0xFF2D1B4E),
        title: Text(
          _isEditing ? 'Edit Note' : 'Add Note',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      // SingleChildScrollView is the fix for the "BOTTOM OVERFLOWED" error —
      // it lets the form scroll up out of the way of the keyboard instead of
      // being squeezed into a fixed-height space with nowhere to go.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildColorPicker(),
                const SizedBox(height: 20),
                _buildLabel('Title'),
                const SizedBox(height: 8),
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildLabel('Description'),
                const SizedBox(height: 8),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildSaveButton(accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.3,
        ),
      );

  Widget _buildColorPicker() {
    return Row(
      children: [
        _buildLabel('Color'),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: noteColorPalette.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final hex = noteColorPalette[index];
                final color = hexToColor(hex);
                final isSelected = hex == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? hexToAccentColor(hex)
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check,
                            size: 18, color: hexToAccentColor(hex))
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D1B4E)),
        decoration: InputDecoration(
          hintText: 'Give your note a title',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: _descriptionController,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF2D1B4E), height: 1.5),
            decoration: InputDecoration(
              hintText: 'Write your note here...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 8,
            minLines: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 4),
          child: Text(
            '$_descLength characters',
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Color accent) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isEditing ? Icons.check : Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isEditing ? 'Update Note' : 'Save Note',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}