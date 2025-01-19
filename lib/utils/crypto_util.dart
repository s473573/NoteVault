import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// This file provides cryptographic utility functions.
class CryptoUtil {
  static const int SALT_LENGTH = 16;
  static const int KEY_LENGTH = 32; // 32 bytes (256 bits)
  
  // generates a semi-secure random byte seq
  static List<int> produceSalt() {
    final random = Random.secure();

    return List<int>.generate(SALT_LENGTH, (i) => random.nextInt(256));
  }

  static Future<List<int>> deriveKey(String password, List<int> salt) async {
    const iterations = 10000;

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: KEY_LENGTH * 8,
    );

    final key = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    
    return key.extractBytes();
  }
  
  ///
  /// A simple way to produce a hash from our key
  ///
  static Future<Hash> produceHash(List<int> key) async {
    final algo = Sha256();
    final digest = await algo.hash(key);

    return digest;
  }
}