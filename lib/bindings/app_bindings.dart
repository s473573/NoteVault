import 'package:get/get.dart';
import 'package:secure_note/controllers/create_note_controller.dart';
import 'package:secure_note/controllers/home_controller.dart';
import 'package:secure_note/controllers/login_controller.dart';
import 'package:secure_note/controllers/note_controller.dart';
import 'package:secure_note/controllers/vault_controller.dart';
import 'package:secure_note/data/repositories/note_repository.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NoteRepository());
    Get.put(NoteController());

    Get.put(LoginController());
    Get.put(VaultRepository());
    Get.put(VaultController());
    Get.put(HomeController());
    Get.put(CreateNoteController());
  }
}