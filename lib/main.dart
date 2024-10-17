import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/screens/vault_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_note_screen.dart';
import 'bindings/app_bindings.dart';

void main() {
  runApp(const MainApp());
}

// DESIGN:
// bottom panel with buttons that go to vault picking screen,
// home screen ( where the notes are at ), and something else
//
// a button could also be in a shape of a note card. Always first

// add a note DONE
  // store it somewhere safe DONE +-
  
// make different vaults of notes
// secure each of them with a password

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
        GetPage(name: '/', page: () => VaultScreen()),
        GetPage(name: '/create_note', page: () => CreateNoteScreen()),
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
          primaryColor: CupertinoColors.activeOrange
        ),
        applyThemeToAll: true
      )
    );
  }
}
