import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';

import 'package:secure_note/data/models/vault.dart';
import 'package:secure_note/data/models/note.dart';

// Vaults are maximum 5mb in size! Should be enough for our layman purposes.

// I bind a vault for operations
class VaultRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // opening a box with an unmatched name will create a new one!
  Future<Box<Note>> openVaultBox(String vaultId, String password) async {
    // deriving a key using PBKDF2
    var key = await _generateEncryptionKey(vaultId, password);
    return Hive.box<Note>(name: 'vault-$vaultId', encryptionKey: base64.encode(key), maxSizeMiB: 5);
  }

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
  List<Note> getNotesFromVault(Box<Note> vaultBox) {
    return vaultBox.getRange(0, vaultBox.length).toList();
  }

  // Close the vault box when done.
  Future<void> closeVaultBox(Box<Note> vaultBox) async {
    vaultBox.close();
  }
  
  static const int SALT_LENGTH = 16;
  static const int KEY_LENGTH = 32; // 32 bytes (256 bits)

  // generates a semi-secure random byte seq
  List<int> produceSalt() {
    final random = Random.secure();

    return List<int>.generate(SALT_LENGTH, (i) => random.nextInt(256));
  }

  Future<List<int>> _getVaultSalt(String vid) async {
    final saltString = await _secureStorage.read(key: vid);
    return saltString != null ? base64Decode(saltString) : await _initializeSalt(vid);
  }

  Future<List<int>> _initializeSalt(String vid) async {
    final salt = produceSalt();
    final saltString = base64Encode(salt);
    await _secureStorage.write(key: vid, value: saltString);
    return salt;
  }

  // the question i should ask is whether there is a salt associated with the vault.
  Future<List<int>> _generateEncryptionKey(String vid, String pass) async {
    final vaultSalt = await _getVaultSalt(vid);

    final iterations = 10000;

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: KEY_LENGTH * 8,
    );

    final key = await pbkdf2.deriveKeyFromPassword(
      password: pass,
      nonce: vaultSalt,
    );

    final keyBytes = await key.extractBytes();
    print('Derived key: ${base64.encode(keyBytes)}');
    return keyBytes;
  }
}
