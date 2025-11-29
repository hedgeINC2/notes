import '../note_model.dart' as model;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperImpl {
  static final DatabaseHelperImpl instance = DatabaseHelperImpl._init();
  static Database? _database;

  DatabaseHelperImpl._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      title TEXT,
      content TEXT,
      time TEXT,
      colorIndex INTEGER
    )
    ''');
  }

  Future<model.Note> create(model.Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap());
    return model.Note(
      id: id,
      title: note.title,
      content: note.content,
      time: note.time,
      colorIndex: note.colorIndex,
    );
  }

  Future<model.Note> readNote(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return model.Note.fromMap(maps.first);
    throw Exception('ID $id not found');
  }

  Future<List<model.Note>> readAllNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'id DESC');
    return result.map((json) => model.Note.fromMap(json)).toList();
  }

  Future<int> update(model.Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
