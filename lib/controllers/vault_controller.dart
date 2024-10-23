import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:secure_note/data/repositories/vault_repository.dart';

class VaultController extends GetxController {
  static const String VAULT_BOX_NAME = "vault-ids";

  final Box<String> _box = Hive.box<String>(name: VAULT_BOX_NAME);
  final VaultRepository _repo = Get.find<VaultRepository>();

  // RxList<String> get vaultIds => _vaultIds;
  
  // @override
  // void onInit() {
  //   super.onInit();
  //   _loadVaultIds();
  // }
  
  // TODO: refactor
  List<String> getVaultIds() {
    if (_box.length == 0) return List.empty();
    return _box.getRange(0, _box.length);
  }
  
  void addVaultId(String id) {
    _box.add(id);
  }
  
  void createVault(String name, String password) {
    _box.add(name);
    _repo.openVaultBox(name, password);
  }
  
  int getLength() {
    return _box.length;
  }
  
  // remove, rename
}