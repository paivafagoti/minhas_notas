import '../models/note.dart';

abstract class NotesRepository {
  Future<List<Note>> listNotes();
  Future<int> insertNote(Note note);
  Future<int> updateNote(Note note);
  Future<int> deleteNote(int id);
}

