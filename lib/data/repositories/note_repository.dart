import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:secure_note/data/models/note.dart';

class NoteRepository extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final RxList<Note> _notes = <Note>[].obs;

  RxList<Note> get notes => _notes;

  @override
  void onInit() {
    super.onInit();
    getAllNotes();
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final storedNotes = await _secureStorage.read(key: 'notes');
      if (storedNotes != null) {
        final List<Map<String, dynamic>> noteList =
            List<Map<String, dynamic>>.from(jsonDecode(storedNotes)
                .map((note) => Map<String, dynamic>.from(note)));
        _notes.assignAll(noteList.map((json) => Note.fromJson(json)).toList());
        return _notes.toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  Future<void> saveNotes() async {
    try {
      final List<Map<String, dynamic>> noteList =
          _notes.map((note) => note.toJson()).toList();
      final String notesJson = jsonEncode(noteList);
      print("Saving notes: $noteList");
      await _secureStorage.write(key: 'notes', value: notesJson);
    } catch (e) {
      print("Error saving notes: $e");
    }
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await saveNotes();
  }

  Future<void> deleteNote(Note note) async {
    _notes.remove(note);
    await saveNotes();
  }
}
