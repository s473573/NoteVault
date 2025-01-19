import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/utils/crypto_util.dart';
import 'package:secure_note/utils/format.dart';

// Vaults are maximum 5mb in size! Should be enough for our layman purposes.


// I bind a vault for operations
// CRUD operations go here:
class VaultRepository {
  static const String VAULT_BOX_NAME = "vault-names";
  final Box<String> _vaultNameBox = Hive.box<String>(name: VAULT_BOX_NAME);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final VaultFormatter formatter = VaultFormatter();
  
  List<String> getAllVaults() {
    final vaults = (_vaultNameBox.length == 0) ?
      List<String>.empty(growable: true) : _vaultNameBox.getRange(0, _vaultNameBox.length);
    print("Stored vault names: $vaults");

    return vaults;
  }
  ///
  /// Remembers this vaults name,
  /// will rewrite existing data!
  ///
  void addVaultName(String name) {
    // for now a name just stores its name and nothing else
    _vaultNameBox.put(name, name);
    print("Vaults after addition: ${getAllVaults()}");
  }
  void removeVaultName(String name) {
    print("Vaults before removal: ${getAllVaults()}");
    _vaultNameBox.delete(name);
    print("Vaults after removal: ${getAllVaults()}");
  }
  Stream<void> watchVaults() => _vaultNameBox.watch();

  // opening a box with an unmatched name will create a new one!
  ///
  /// Im trying to open this vault with an already valid password
  ///
  Future<Box<Note>> openVaultBox(String vaultId, String password) async {
    // deriving a key using PBKDF2
    var key = await _generateEncryptionKey(vaultId, password); // this could overwrite wrong salt!
    return Hive.box<Note>(name: vaultId, encryptionKey: base64.encode(key), maxSizeMiB: 5);
  }

  Future<Box<Note>> openVault(String vaultId, String password) async {
    // this wouldnt hurt
    final isValid = await validateVaultPassword(vaultId, password);
    if (isValid) {
      return await openVaultBox(vaultId, password);
    } else {
      throw PasswordValidationException('Invalid password for vault ID: $vaultId');
    }
  }
  
  ///
  /// Creating a vault involves generating an encryption key,
  /// building and securing a box (a formatted id is passed) to hold notes in,
  /// retaining the ability to authenticate
  ///
  Future<void> createVault(String vaultId, String password) async {
    await _initializeSalt(vaultId); // writing a new salt
    var key = await _generateEncryptionKey(vaultId, password);
    await _storeVaultKeyHash(vaultId, key); // and a new hash
    try {
      Hive.box<Note>(name: vaultId, encryptionKey: base64.encode(key), maxSizeMiB: 5);
    } catch (err) {
      print("Hive box error: $err");
    }
  }
  
  ///
  /// Sanity check: if im validating a password for a thing,
  /// that thing already exists
  ///
  Future<bool> validateVaultPassword(String vaultId, String inputPassword) async {
    final derivedKey = await _generateEncryptionKey(vaultId, inputPassword);
    final derivedDigest = await CryptoUtil.produceHash(derivedKey);
    final derivedHash = base64Encode(derivedDigest.bytes);
    print("Derived hash for password ($inputPassword): $derivedHash");
    
    final storedHash = await _readVaultKeyHash(vaultId);
    print("Stored hash : $storedHash");

    // Compare!
    return (derivedHash == storedHash);
  }

  
  // This method should return a Vault object, which is essentially a wrapper
  // for the boxed content (notes) + metadata
  // Future<Vault> openVault(String name, String password) {

  // }

  // Adds a new note to a specific vault.
  Future<void> addNoteToVault(Box<Note> vaultBox, Note note) async {
    vaultBox.add(note);
  }

  // Deletes a note from a specific vault by its index.
  Future<void> deleteNoteFromVault(Box<Note> vaultBox, int noteIndex) async {
    vaultBox.deleteAt(noteIndex);
  }

  // Fetches all notes from the given vault.
  // using getRange as there seems to be no other way
  // TODO: tis cleaner to construct a list on the fly using every key from .keys attrib !
  List<Note> getNotesFromVault(Box<Note> vaultBox) {
    return vaultBox.getRange(0, vaultBox.length).toList();
  }

  // Should consume the Box
  Future<void> lockVaultBox(Box<Note> vaultBox) async {
    vaultBox.close();
  }
  ///
  /// Consumes and wipes the box,
  /// cleans key hash,
  /// cleans its salt
  ///
  Future<void> destroyVault(Box<Note> vaultBox) async {
    final vid = vaultBox.name;
    print("Destroying vault ID: $vid");

    vaultBox.clear();
    vaultBox.deleteFromDisk();
    
    print("Wiping salt and hash values...");
    await _wipeSalt(vid);
    await _wipeVaultKeyHash(vid);
  }
  
  ///
  /// This shouldnt do any front end stuff like checking passwords
  /// doing less thing with more security awareness
  ///
  Future<Box<Note>> relockVault(Box<Note> oldBox, String newPassword) async {
    // Close and delete the old vault
    var id = oldBox.name;
    print("Relocking vault ID: $id with new password: $newPassword");
    await this.destroyVault(oldBox);
    print("Destroyed old one");

    // same name, new vault!
    await createVault(id, newPassword);
    print("Created a new one!");
    return openVaultBox(id, newPassword);
  }

  ///
  /// This should make a tiny performance improvement,
  /// since the derivation itself is constly and made often
  ///
  Future<void> _storeVaultKeyHash(String vid, List<int> key) async {
    // Deriving the key
    // final keyBytes = await _generateEncryptionKey(vid, pass);  // returns List<int>
    final digest = await CryptoUtil.produceHash(key);
    final hashString = base64Encode(digest.bytes);

    // Storing the hash in secure storage, under a certain format
    await _secureStorage.write(key: formatter.hash(vid), value: hashString);
  }
  Future<String> _readVaultKeyHash(String vid) async {
    final storedHash = await _secureStorage.read(key: formatter.hash(vid));
    if (storedHash == null) {
      throw StateError('No stored key hash found for vault: $vid');
    }
    return storedHash;
  }
  Future<void> _wipeVaultKeyHash(String vid) async {
    _secureStorage.delete(key: formatter.hash(vid));
  }
  
  ///
  /// Reads a salt and if not present (that means its a new vault),
  /// initializes a new salt
  ///
  Future<List<int>> _produceVaultSalt(String vid) async {
    final saltString = await _secureStorage.read(key: formatter.salt(vid));
    if (saltString == null) { print("No salt for vault ID: $vid"); }
    return saltString != null ? base64Decode(saltString) : await _initializeSalt(vid);
  }
  Future<List<int>> _initializeSalt(String vid) async {
    print("Initializing a salt for vault ID: $vid");

    final salt = CryptoUtil.produceSalt();
    final saltString = base64Encode(salt);
    await _secureStorage.write(key: formatter.salt(vid), value: saltString);
    return salt;
  }
  Future<void> _wipeSalt(String vid) async {
    _secureStorage.delete(key: formatter.salt(vid));
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
}

class PasswordValidationException implements Exception {
  final String message;
  PasswordValidationException([this.message = 'Password validation failed']);

  @override
  String toString() => 'PasswordValidationException: $message';
}