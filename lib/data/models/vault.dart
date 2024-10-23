import 'package:hive/hive.dart';

import 'note.dart';

class Vault {
  Vault({
    required this.name,
    required this.passwordHash,
    required this.box
  });

  final String name;
  final String passwordHash;
  final Box<Note> box;
}