import 'dart:convert';
import '../note_model.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelperImpl {
  static final DatabaseHelperImpl instance = DatabaseHelperImpl._init();
  static const String _notesKey = 'notes_app_notes';

  DatabaseHelperImpl._init();

  Future<List<model.Note>> _readListFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => model.Note.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _writeListToPrefs(List<model.Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notes.map((n) => n.toMap()).toList());
    await prefs.setString(_notesKey, encoded);
  }

  Future<model.Note> create(model.Note note) async {
    final notes = await _readListFromPrefs();
    final nextId = (notes.isEmpty)
        ? 1
        : (notes.map((n) => n.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final newNote = model.Note(
      id: nextId,
      title: note.title,
      content: note.content,
      time: note.time,
      colorIndex: note.colorIndex,
    );
    notes.insert(0, newNote);
    await _writeListToPrefs(notes);
    return newNote;
  }

  Future<model.Note> readNote(int id) async {
    final notes = await _readListFromPrefs();
    final found = notes.where((n) => n.id == id).toList();
    if (found.isNotEmpty) return found.first;
    throw Exception('ID $id not found');
  }

  Future<List<model.Note>> readAllNotes() async {
    final notes = await _readListFromPrefs();
    notes.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return notes;
  }

  Future<int> update(model.Note note) async {
    final notes = await _readListFromPrefs();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx == -1) return 0;
    notes[idx] = note;
    await _writeListToPrefs(notes);
    return 1;
  }

  Future<int> delete(int id) async {
    final notes = await _readListFromPrefs();
    final before = notes.length;
    notes.removeWhere((n) => n.id == id);
    await _writeListToPrefs(notes);
    return before - notes.length;
  }
}
