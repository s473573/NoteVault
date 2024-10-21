class Vault {
  Vault({required this.name, required this.passwordHash});

  final String name;
  final String passwordHash;
  
  static Vault jsonWrapper(dynamic json) {
    return Vault.fromJson(json as Map<String, dynamic>);
  }

  factory Vault.fromJson(Map<String, dynamic> json) => Vault(
    name: json['name'] as String,
    passwordHash: json['pass'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'pass': passwordHash,
  };
}