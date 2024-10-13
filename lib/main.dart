// ignore_for_file: constant_identifier_names

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
  
  static const _app_name = "Secure Note";

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
        brightness: Brightness.dark,
      )
    );
  }
}
