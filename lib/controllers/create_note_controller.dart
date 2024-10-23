import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/home_controller.dart';

import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';

class CreateNoteController extends GetxController {
  final VaultRepository repo = Get.find();
  final HomeController con = Get.find();

  Future<void> saveNote(String name, String content) async {
    try {
      // Create a new note using the NoteController
      repo.addNoteToVault(con.getVault(), Note(
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
