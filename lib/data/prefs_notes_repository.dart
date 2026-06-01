import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import 'notes_repository.dart';

class PrefsNotesRepository implements NotesRepository {
  static const _key = 'notes_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<int> deleteNote(int id) async {
    final notes = await listNotes();
    final before = notes.length;
    final updated = notes.where((n) => n.id != id).toList(growable: false);
    await _writeAll(updated);
    return before - updated.length;
  }

  @override
  Future<int> insertNote(Note note) async {
    final notes = await listNotes();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final created = note.copyWith(id: newId);
    await _writeAll([created, ...notes]);
    return newId;
  }

  @override
  Future<List<Note>> listNotes() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    final notes = decoded
        .whereType<Map>()
        .map((m) => Note.fromMap(m.cast<String, Object?>()))
        .toList(growable: false);

    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  @override
  Future<int> updateNote(Note note) async {
    final id = note.id;
    if (id == null) return 0;
    final notes = await listNotes();
    final idx = notes.indexWhere((n) => n.id == id);
    if (idx == -1) return 0;

    final updated = [...notes];
    updated[idx] = note;
    await _writeAll(updated);
    return 1;
  }

  Future<void> _writeAll(List<Note> notes) async {
    final prefs = await _prefs;
    final raw = jsonEncode(notes.map((n) => n.toMap()).toList(growable: false));
    await prefs.setString(_key, raw);
  }
}

