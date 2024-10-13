import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:secure_note/data/repositories/note_repository.dart';
import 'package:secure_note/data/models/note.dart';

class CreateNoteController extends GetxController {
  final NoteRepository repo = Get.find();

  Future<void> saveNote(String name, String content) async {
    try {
      // Create a new note using the NoteController
      repo.addNote(Note(
        id: UniqueKey().toString(), // Assuming you want a unique identifier
        name: name,
        content: content,
      ));

      // Print a success message (you can replace this with your desired feedback mechanism)
      print('Note saved successfully');
    } catch (e) {
      // Handle errors (you can replace this with your desired error handling)
      print('Error saving note: $e');
    }
  }
}
