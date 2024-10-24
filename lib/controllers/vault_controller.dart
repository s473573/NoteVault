import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';

// UI-related logic
class VaultController extends GetxController {
  static const String VAULT_BOX_NAME = "vault-ids";

  final Box<String> _box = Hive.box<String>(name: VAULT_BOX_NAME);
  final VaultRepository _repo = Get.find<VaultRepository>();

  var vaultIds = <String>[].obs;
  // RxList<String> get vaultIds => _vaultIds;
  
  @override
  void onInit() {
    super.onInit();
    _fetchVaultIds();
  }
  
  void _fetchVaultIds() {
    vaultIds.value = (_box.length == 0) ?
      List.empty() : _box.getRange(0, _box.length);
  }
  
  // // TODO: refactor
  // List<String> getVaultIds() {
  //   if (_box.length == 0) return List.empty();
  //   return _box.getRange(0, _box.length);
  // }
  
  void _addVaultId(String id) {
    _box.add(id);
    vaultIds.add(id);
  }
  
  void createVault(String name, String password) async {
    _addVaultId(name);

    var vault = await _repo.openVaultBox(name, password);
    vault.close();
  }
  
  // TODO: refactor this hack
  Future<bool> unlockVault(String name, String password) async {
    try {
      await _repo.openVaultBox(name, password);
      return true;
    }
    catch (_) {
      return false;
    }
  }
  
  int getLength() {
    return _box.length;
  }
  
  // remove, rename
}