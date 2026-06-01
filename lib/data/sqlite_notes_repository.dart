import '../db/app_database.dart';
import '../models/note.dart';
import 'notes_repository.dart';

class SqliteNotesRepository implements NotesRepository {
  final AppDatabase _db;

  SqliteNotesRepository(this._db);

  @override
  Future<int> deleteNote(int id) => _db.deleteNote(id);

  @override
  Future<int> insertNote(Note note) => _db.insertNote(note);

  @override
  Future<List<Note>> listNotes() => _db.listNotes();

  @override
  Future<int> updateNote(Note note) => _db.updateNote(note);
}

