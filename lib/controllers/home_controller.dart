import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';

class HomeController extends GetxController {
  final VaultRepository repo = Get.find();
  late Box<Note> _box;

  RxList<Note> notes = <Note>[].obs;
  
  // @override
  // void onInit() {
  //   super.onInit();
  //   assignNotes();
  // }
  
  Future<void> assignNotes() async {
    notes.value = repo.getNotesFromVault(_box);
  }
  
  Future<void> bindVault(String name, String password) async {
    _box = await repo.openVaultBox(name, password);
  }
  
  Future<void> initVault(String name, String password) async {
    await bindVault(name, password);
    await assignNotes();
  }
  
  Box<Note> getVault() {
    return _box;
  }
}