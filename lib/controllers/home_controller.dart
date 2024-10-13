import 'package:get/get.dart';

import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/data/repositories/note_repository.dart';

class HomeController extends GetxController {
  final NoteRepository repo = Get.find();
  RxList<Note> notes = <Note>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    assignNotes();
  }
  
  Future<void> assignNotes() async {
    notes = repo.notes;
  }
  
}