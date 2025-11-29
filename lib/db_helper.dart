// Platform-aware database helper facade.
// Uses conditional imports to pick an implementation for web vs IO.

import 'note_model.dart';

export 'note_model.dart';

import 'src/db_helper_web.dart'
    if (dart.library.io) 'src/db_helper_io.dart'
    as impl;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  Future<Note> create(Note note) =>
      impl.DatabaseHelperImpl.instance.create(note);
  Future<Note> readNote(int id) =>
      impl.DatabaseHelperImpl.instance.readNote(id);
  Future<List<Note>> readAllNotes() =>
      impl.DatabaseHelperImpl.instance.readAllNotes();
  Future<int> update(Note note) =>
      impl.DatabaseHelperImpl.instance.update(note);
  Future<int> delete(int id) => impl.DatabaseHelperImpl.instance.delete(id);
}
