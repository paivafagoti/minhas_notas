import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'meu_app.db';
  static const _dbVersion = 1;

  static const notesTable = 'notes';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $notesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert(notesTable, note.toMap());
  }

  Future<List<Note>> listNotes() async {
    final db = await database;
    final rows = await db.query(
      notesTable,
      orderBy: 'created_at DESC',
    );
    return rows.map(Note.fromMap).toList(growable: false);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateNote(Note note) async {
    final id = note.id;
    if (id == null) return 0;
    final db = await database;
    return db.update(
      notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
