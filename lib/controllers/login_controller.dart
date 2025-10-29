import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:secure_note/utils/format.dart';
import 'package:secure_note/utils/vault_crypto_service.dart';
import 'package:secure_note/utils/vault_input_validation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LoginController extends GetxController {
  var isMasterPasswordSet = false.obs;
  var password = ''.obs;
  RxString passwordError = ''.obs;
  // var shakeOffset = 0.0.obs;

  final _localAuth = LocalAuthentication();
  final vaultCrypto = VaultCryptoService(
      secureStorage: const FlutterSecureStorage(),
      formatter:
          VaultFormatter(namespace: 'notevault', vaultType: 'masterkey'));

  @override
  void onInit() async {
    super.onInit();

    // deciding whether the user set the password
    isMasterPasswordSet.value = await vaultCrypto.isMasterKeySet();
  }

  // validate input and proceed picking your vault!
  Future<void> handleSubmit() async {
    final bool isValid = await validateMasterPassword(password.value);
    if (!isValid) {
      return;
    }

    if (isMasterPasswordSet.value) {
      if (await vaultCrypto.validateVaultHash(
          VaultCryptoService.MASTERPASS_KEY, password.value))
        Get.offNamed('/vault-collection');
      else
        passwordError.value = "Wrong password.";
    } else {
      _setMasterPassword(password.value);
      Get.offNamed('/vault-collection');
    }
  }

  Future<bool> validateMasterPassword(String password) async {
    // input validation
    final passError = VaultInputValidator.validatePassword(password);
    passwordError.value = passError ?? '';

    return (passError == null);
  }

  void _setMasterPassword(String newPassword) async {
    vaultCrypto.initializeVaultKey(
        VaultCryptoService.MASTERPASS_KEY, newPassword);

    isMasterPasswordSet.value = true;
  }

  /// Face ID
  Future<void> authenticateWithFaceID() async {
    // check if supported
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isDeviceSupported = await _localAuth.isDeviceSupported();

    if (!canCheckBiometrics && !isDeviceSupported) {
      passwordError.value = 'No FaceID on your device!';
      return;
    }

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Use FaceID to authenticate in Vault Collection.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true, // keeping the session
        ),
      );

      if (didAuthenticate) {
        Get.offNamed('/vault-collection');
      } else {
        passwordError.value = 'Face ID Authentication failed or canceled!';
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        passwordError.value = 'Face ID is not enrolled on this device.';
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        passwordError.value = 'Too many attempts. Face ID is locked.';
      } else {
        passwordError.value = 'Face ID error: $e';
      }
    }
  }
}
