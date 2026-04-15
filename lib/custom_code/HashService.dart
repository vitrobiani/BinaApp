import 'dart:convert'; // For utf8.encode

import 'package:crypto/crypto.dart'; // For sha256

class HashService {
  // Simple SHA-256 Hashing

  static String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes

    var digest = sha256.convert(bytes); // Create the hash

    return digest.toString(); // Return as Hex string
  }

  // Recommended: SHA-256 with Salting

  static String hashWithSalt(String password, String salt) {
    var bytes = utf8.encode(password + salt);

    var digest = sha256.convert(bytes);

    return digest.toString();
  }
}
