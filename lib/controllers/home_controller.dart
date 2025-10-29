import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';
import 'package:secure_note/utils/format.dart';

class HomeController extends GetxController {
  final VaultRepository vault_api = Get.find();
  final VaultFormatter formatter = VaultFormatter();
  late Box<Note> _vault;
  Rx<String> name = 'Invalid Vault'.obs;
  Rx<String> passwordError = ''.obs;

  RxList<Note> noteCollection = <Note>[].obs;

  final isStatisticsVisible = false.obs;

  void toggleStatistics() {
    isStatisticsVisible.value = !isStatisticsVisible.value;
    print("isStatisticsVisible: ${isStatisticsVisible.value}");
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   assignNotes();
  // }

  ///
  /// Would be nice to implement a rename feature too!
  ///
  ///

  Future<void> _assignName(String name) async {
    this.name.value = name;
  }

  Future<void> _assignNotes() async {
    this.noteCollection.value = vault_api.getNotesFromVault(_vault);
  }

  ///
  /// Loads the chosen vault into memory,
  /// essentialy opens and assigns its boxed content
  /// generates an ID from name, for authentication and later password validation
  ///
  Future<void> _bindVault(String name, String password) async {
    this._vault =
        await vault_api.openVault(formatter.constructVaultId(name), password);
  }

  ///
  /// Checks if the key is correct and,
  /// in that case opens the associated vault, its boxed content
  /// and loads it to memory
  ///
  Future<void> initVault(String name, String password) async {
    print("Initializing vault: $name");
    try {
      await _bindVault(name, password);
    } catch (err) {
      print("Failed to unpack the vault! Error: $err");
      rethrow;
    }
    await _assignName(name);
    await _assignNotes();
    print("Successfully decrypted and loaded vault: $name.");
  }

  Box<Note> getVault() {
    return _vault;
  }

  String getVaultCreationDate(String vaultName) {
    // Fetch creation date from your vault metadata
    return '01.01.2025'; // Example
  }

  /// an animation for refreshed vault? like notes are restacked
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      // check if the password is correct
      // call check password method
      var relockedVault = await vault_api.relockVault(_vault, newPassword);
      // refill with notes
      for (final note in this.noteCollection) {
        await vault_api.addNoteToVault(relockedVault, note);
      }
      relockedVault.close();
    } catch (err) {
      final String errorMessage = "Error changing the password: $err";
      print(errorMessage);
      passwordError.value = errorMessage;
    } finally {
      // init again
      await initVault(this.name.value, newPassword);
      print("Password changed successfully");
    }
  }

  ///
  /// bye-bye binded vault!
  ///
  void removeVault() async {
    await vault_api.destroyVault(_vault);
    vault_api.removeVaultName(name.value);
  }
}
