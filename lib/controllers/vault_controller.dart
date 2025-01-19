import 'dart:async';

import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';
import 'package:secure_note/utils/format.dart';

// UI-related logic
class VaultController extends GetxController {
  // final Box<String> _nameBook = Hive.box<String>(name: VAULT_BOX_NAME);
  final VaultRepository _repo = Get.find<VaultRepository>();
  final VaultFormatter formatter = VaultFormatter();

  var vaultNames = <String>[].obs;
  late final StreamSubscription<void> _vaultBoxSubscription; 
  void _fetchVaults () => vaultNames.value = _repo.getAllVaults();

  @override
  void onInit() {
    super.onInit();

    // initializing names from persistence
    _fetchVaults();
    // keeping track of box changes
    _vaultBoxSubscription = _repo.watchVaults().listen((event) {
      _fetchVaults();
     });
  }
  @override
  void onClose() {
    // Cancel the subscription when the controller is disposed
    _vaultBoxSubscription.cancel();
    super.onClose();
  }
  
  
  // void _fetchVaultIds() {
  //   print("Stored vault names: $_nameBook");
  //   nameList.value = (_nameBook.length == 0) ?
  //     List.empty(growable: true) : _nameBook.getRange(0, _nameBook.length);
  // }
  
  // // TODO: refactor
  // List<String> getVaultIds() {
  //   if (_box.length == 0) return List.empty();
  //   return _box.getRange(0, _box.length);
  // }
  
  
  ///
  /// Starts to keep track of the name of the vault,
  /// constructs an id and uses it to
  /// write one on disk and encrypt if new.
  ///
  void createVault(String name, String password) async {
    _repo.addVaultName(name);
    print("Keeping track of vault named $name !");

    final vaultId = formatter.constructVaultId(name);
    await _repo.createVault(vaultId, password);
    print("Successfully created a vault with id: $vaultId .");
  }

  ///
  /// Clears the box, removes its name from everywhere
  ///
  void deleteVault(String name, String password) async {
    try {
      var vid = formatter.constructVaultId(name);
      var vault = await _repo.openVaultBox(vid, password);
      await _repo.destroyVault(vault);
      print("Successfully destroyed the vault $name!");
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete vault: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
    _repo.removeVaultName(name);
    print("Successfully forgot the $name name!");
  }
  
  ///
  /// Checks if it can open a vault with a given password.
  /// Warning: this effectively conceals the inner-debug error messages,
  /// simplyfying them as password-related only
  ///
  Future<bool> unlockVault(String name, String password) async {
    // TODO: should I include a check if theres a vault with a given name?
    final vid = formatter.constructVaultId(name);
    print("Validating password: $password for vault $vid...");
    return _repo.validateVaultPassword(vid, password)
        .then((_) => true)
        .catchError((_) => false);
  }
}