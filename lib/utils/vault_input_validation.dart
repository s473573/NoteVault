class VaultInputValidator {
  // Name: 2 to 15 alphanumeric, no spaces or special chars
  static final RegExp _vaultNameRegex = RegExp(r'^[a-zA-Z0-9]{2,15}$');

  static String? validateVaultName(String name) {
    if (name.isEmpty) {
      return 'Vault name is required.';
    }
    if (!_vaultNameRegex.hasMatch(name)) {
      return 'Only alphanumeric (2-15 chars), no spaces.';
    }

    return null;
  }

  // Min length 4.
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 4) {
      return 'Min 4 characters for password.';
    }
    // might enforce stronger complexity, e.g. at least 1 digit, 1 letter, etc.
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password)) {
    //   return 'Password must have uppercase, lowercase, and a digit (8+ chars).';
    // }

    return null;
  }
}
