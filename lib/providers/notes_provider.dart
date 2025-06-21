import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note.dart';

/// A [ChangeNotifier] that manages notes stored in Hive.
class NotesProvider extends ChangeNotifier {
  NotesProvider() {
    _loadNotes();
  }

  final Box<Note> _notesBox = Hive.box<Note>('notes');

  List<Note> _notes = [];

  /// Unmodifiable view of the loaded notes.
  List<Note> get notes => List.unmodifiable(_notes);

  void _loadNotes() {
    _notes = _notesBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  /// Adds a new [note] and notifies listeners of the change.
  Future<void> addNote(Note note) async {
    await _notesBox.put(note.id, note);
    _loadNotes();
  }
}
