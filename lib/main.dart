import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_note/screens/login_screen.dart';
import 'package:secure_note/screens/vault_screen.dart';

import 'data/models/note.dart';
import 'screens/home/create_note_screen.dart';
import 'bindings/app_bindings.dart';
import 'screens/home/home_screen.dart';

Future<void> initDB() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

  // registering note model here
  Hive.registerAdapter('Note', Note.jsonWrapper);
}

void main() async {
  await initDB();
  runApp(const MainApp());
}

// DESIGN:
// bottom panel with buttons that go to vault picking screen,
// home screen ( where the notes are at ), and something else
//
// a button could also be in a shape of a note card. Always first

// add a note DONE
// store it somewhere safe DONE +-

// make different vaults of notes DONE
// secure each of them with a password DONE
// make ability to remove a vault DONE
// make it possible for user to change the given vault password DONE

// sanitize all user input, focusing on sensitive and dangerous info like passwords
// maybe sanitize vault names too (no spaces or anything weird like that!) DONE

// TODO:
// implement face-id entry
// provide a choice between good-old symbols and city-sleek face-id

// TODO:
// extend information stored about a vault to a json-serialized object,
// with metadata fields about a vault instance

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const _app_name = "NoteVault";

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
        title: _app_name,
        initialBinding: AppBindings(),
        initialRoute: '/',
        getPages: [
          // GetPage(name: '/', page: () => HomeScreen()),
          //GetPage(name: '/', page: () => VaultScreen()),
          GetPage(name: '/', page: () => LoginScreen()),
          GetPage(name: '/vault-collection', page: () => VaultScreen()),
          GetPage(name: '/create_note', page: () => CreateNoteScreen()),
          GetPage(name: '/vault', page: () => HomeScreen()),
        ],
        theme: const CupertinoThemeData(
            barBackgroundColor: CupertinoColors.black,
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.activeOrange,
            textTheme: CupertinoTextThemeData(
                navTitleTextStyle: TextStyle(
                    color: CupertinoColors.activeOrange,
                    fontFamily: 'SF Pro Display',
                    fontSize: 26,
                    fontWeight: FontWeight.w400),
                primaryColor: CupertinoColors.activeOrange),
            applyThemeToAll: true));
  }
}
