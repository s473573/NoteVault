// home_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:secure_note/controllers/home_controller.dart';
import 'package:secure_note/data/models/note.dart';

// add max length to a note card, so notes would not be even in height.

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  HomeScreen({super.key});

  // TODO: refactor this dirty draft-up
  @override
  Widget build(BuildContext context) {
    // [name, password]
    final List<String> args = Get.arguments;

    return FutureBuilder<void>(
      future: controller.initVault(args[0], args[1]),
      builder: (context, snapshot) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Column(
              children: [
                CupertinoNavigationBar(
                  leading: Text(
                    'My Secure Notes',
                    style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  trailing: CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage(
                        'no-image-yet.png'),
                  ),
                  border: Border(
                    bottom: BorderSide(width: 0.0, color: Colors.transparent),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      // UNIMPLEMENTED 
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() {
                      return GridView.builder(
                        itemCount: controller.notes.length,
                        // grid config
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // max two columns
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final Note note = controller.notes[index];
                          return NoteCardWidget(note: note);
                        },
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width / 2 - 35,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: CupertinoColors.darkBackgroundGray
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.add,
                        size: 35,
                      ),
                      onPressed: () {
                        Get.toNamed('/create_note');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class NoteCardWidget extends StatelessWidget {
  final Note note;

  NoteCardWidget({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.darkBackgroundGray,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          // TODO: create preview
          Text(
            note.content.length > 50
                ? note.content.substring(0, 50) + '...'
                : note.content,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "11.22.63", // TODO: handle dates
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
