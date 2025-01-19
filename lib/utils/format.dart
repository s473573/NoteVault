class VaultFormatter {
  final String namespace;
  final String vaultType;

  VaultFormatter({this.namespace = 'notevault', this.vaultType = 'standard'});

  ///
  /// A simple function that produces and id for a vault from its name,
  /// open for future reimplementation or/and improvement
  ///
  String constructVaultId(String name) {
    return '$namespace:$vaultType:$name';
  }

  String constructKey(String vaultId, String keyType) {
    final formattedVaultId = constructVaultId(vaultId);
    return '$formattedVaultId:$keyType';
  }

  // Specific helper methods for common key types
  String salt(String vaultId) => constructKey(vaultId, 'salt');
  String hash(String vaultId) => constructKey(vaultId, 'hash');
}
