import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'screens/home_screen.dart';
import 'screens/create_note_screen.dart';
import 'bindings/app_bindings.dart';

void main() {
  runApp(const MainApp());
}

// add a note
  // store it somewhere safe
  
// secure a note

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
        GetPage(name: '/', page: () => HomeScreen()),
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
