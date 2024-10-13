// home_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:secure_note/controllers/home_controller.dart';
import 'package:secure_note/controllers/note_controller.dart';
import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/widgets/NoteWidget.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('MOST SECURE NOTES'),
      ),
      child: SafeArea(
        child: Container(
        margin: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: CupertinoColors.darkBackgroundGray,
            width: 10.0
          ),
        ),
          child: Stack(
            children: [
              Obx(
                () { return ListView.builder(
                   itemCount: controller.notes.length,
                   itemBuilder: (context, index) {
                     final Note note = controller.notes[index];
                     final NoteController c = Get.find();
                     c.notesExpanded[note.id] = RxBool(false);
                
                     return NoteWidget(note: note);
                   });
               }),
              
                // return ListView.builder(
                //   itemCount: notes.length,
                //   itemBuilder: (context, index) {
                //     final note = controller.notes[index];
                //     return Column(
                //       children: [
                //         CupertinoListTile(
                //           title: Text(
                //             note.name,
                //             style: const TextStyle(fontSize: 18.0),
                //           ),
                //           subtitle: Text(
                //             'ID: ${note.id}',
                //             style: const TextStyle(fontSize: 14.0),
                //           ),
                //           onTap: () {
                //             controller.toggleExpansion(note.id);
                //           },
                //         ),
                //         // if (controller.expandedId.value == note.id)
                //         if (note.id == controller.expandedId.value)
                //           ExpansionWidget(content: note.content)
                //       ],
                //     );
                //   },
                // );
              Positioned(
                  left: 120,
                  right: 120,
                  bottom: MediaQuery.of(context).size.height / 10,
                  child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: CupertinoColors.darkBackgroundGray,),
                      height: MediaQuery.of(context).size.height / 10,
                      child: Center(
                        child: CupertinoButton(
                            child: const Icon(
                              CupertinoIcons.add,
                              color: CupertinoColors.white,
                            ),
                            onPressed: () {
                              Get.toNamed('/create_note');
                            }),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
