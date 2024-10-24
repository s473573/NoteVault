import 'package:hive/hive.dart';

import 'note.dart';

// It be real sweet If its possible to nest boxes
class Vault {
  Vault({
    required this.name,
    required this.box,
    required this.creationDate,
  });

  final String name;
  final DateTime creationDate;
  final Box<Note> box;
  
  // Something like that
  // factory Vault.createNew(String name, String password ... ) {
  //   return Vault(
  //     name: name,
  //     box: Hive.box(),
  //     creationDate: DateTime.now(),
  //   );
  // }
}