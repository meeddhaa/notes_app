# Notes App

A simple notes app built with Flutter and Cloud Firestore — create, view, edit, and delete notes, synced live to the cloud.


## What it does

- Add a note with a title and description
- See all your notes in a live-updating list
- Tap a note to edit it
- Swipe to delete, with an undo option
- Search your notes
- Pick a color for each note

## Stack

Flutter + Cloud Firestore, with a small service layer (`NoteService`) that handles all the database logic separately from the UI.


## Structure

```
lib/
├── main.dart
├── models/note.dart
├── services/note_service.dart
├── screens/notes_list_screen.dart
├── screens/add_edit_note_screen.dart
└── utils/
```