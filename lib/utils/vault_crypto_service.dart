// vault_crypto_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_note/utils/crypto_util.dart';
import 'dart:convert';

import 'package:secure_note/utils/format.dart';

class VaultCryptoService {
  final FlutterSecureStorage secureStorage;
  final VaultFormatter formatter;

  VaultCryptoService({
    required this.secureStorage,
    required this.formatter,
  });

  static const String MASTERPASS_KEY = 'master-pass';
  
  Future<List<int>> initializeVaultKey(String vaultId, String pass) async {
    await _initializeSalt(vaultId); // writing a new salt
    var key = await _generateEncryptionKey(vaultId, pass);
    await storeVaultKeyHash(vaultId, key); // and a new hash
    
    return key;
  }
  Future<List<int>> deriveVaultKey(String vaultId, String pass) async {
    return await _generateEncryptionKey(vaultId, pass); // this could overwrite wrong salt!
  }
  
  ///
  /// Sanity check: if im validating a password for a thing,
  /// that thing already exists
  ///
  Future<bool> validateVaultHash(String vaultId, String pass) async {
    final derivedKey = await _generateEncryptionKey(vaultId, pass);
    final derivedDigest = await CryptoUtil.produceHash(derivedKey);
    final derivedHash = base64Encode(derivedDigest.bytes);
    print("Derived hash for password ($pass): $derivedHash");
    
    final storedHash = await readVaultKeyHash(vaultId);
    print("Stored hash : $storedHash");

    // Compare!
    return (derivedHash == storedHash);
  }

  ///
  /// This should make a tiny performance improvement,
  /// since the derivation itself is constly and made often
  ///
  Future<void> storeVaultKeyHash(String vid, List<int> key) async {
    // Deriving the key
    // final keyBytes = await __generateEncryptionKey(vid, pass);  // returns List<int>
    final digest = await CryptoUtil.produceHash(key);
    final hashString = base64Encode(digest.bytes);

    // Storing the hash in secure storage, under a certain format
    await secureStorage.write(key: formatter.hash(vid), value: hashString);
  }
  Future<String> readVaultKeyHash(String vid) async {
    final storedHash = await secureStorage.read(key: formatter.hash(vid));
    if (storedHash == null) {
      throw StateError('No stored key hash found for vault: $vid');
    }
    return storedHash;
  }
  Future<void> wipeVaultKeyHash(String vid) async {
    secureStorage.delete(key: formatter.hash(vid));
  }
  
  ///
  /// Reads a salt and if not present (that means its a new vault),
  /// initializes a new salt
  ///
  Future<List<int>> _produceVaultSalt(String vid) async {
    final saltString = await secureStorage.read(key: formatter.salt(vid));
    if (saltString == null) { print("No salt for vault ID: $vid"); }
    return saltString != null ? base64Decode(saltString) : await _initializeSalt(vid);
  }
  Future<List<int>> _initializeSalt(String vid) async {
    print("Initializing a salt for vault ID: $vid");

    final salt = CryptoUtil.produceSalt();
    final saltString = base64Encode(salt);
    await secureStorage.write(key: formatter.salt(vid), value: saltString);
    return salt;
  }
  Future<void> wipeSalt(String vid) async {
    secureStorage.delete(key: formatter.salt(vid));
  }

  ///
  /// Derives a key for this vault using a dedicated salt,
  /// if no salt is present, generates it too
  ///
  Future<List<int>> _generateEncryptionKey(String vid, String pass) async {
    final vaultSalt = await _produceVaultSalt(vid);

    final keyBytes = await CryptoUtil.deriveKey(pass, vaultSalt);
    print('Derived key: ${base64.encode(keyBytes)}');

    return keyBytes;
  }
  
  ///
  /// Checks whether theres Vault Master Key set.
  ///
  Future<bool> isMasterKeySet() async {
    final isSet = await secureStorage.containsKey(key: MASTERPASS_KEY);
    if (!isSet) { print("Master password is not set."); }
    return isSet;
  }
}