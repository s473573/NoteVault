import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/note_controller.dart';
import 'package:secure_note/data/models/note.dart';

// sliding out animation

class NoteWidget extends StatelessWidget {
  final Note note;
  final NoteController controller = Get.find();

  NoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    var isExpanded = controller.notesExpanded[note.id];

    return Container(
      padding: EdgeInsets.all(5),
      color: CupertinoColors.darkBackgroundGray,
      child: Column(
        children: [
        CupertinoCard(text: note.name, callback: () {
          controller.animController.reset();
          controller.notesExpanded[note.id]?.value = !controller.notesExpanded[note.id]!.value;
          controller.animController.forward();
        },),
         Text('ID: ${note.id}', style: const TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
         const SizedBox(height: 4.0,),
         Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            padding: EdgeInsets.only(bottom: 20.0),
            child: SlideTransition(
              position: controller.slideAnimation,
              child: Visibility(
                visible: isExpanded!.isTrue,
                child: Text(
                    note.content,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
              ),
            ),
          )
         )
        ]
      ),
    );
  }
}

class CupertinoCard extends StatelessWidget {
  final String text;
  final String imageDir;
  final VoidCallback? callback;

  const CupertinoCard({
    super.key, 
    required this.text,
    this.imageDir = "",
    this.callback,
    });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
          onPressed: callback ?? () {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('Card is clicked.'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('ok'),
                        onPressed: () {
                          Navigator.pop(context, 'ok');
                        },
                      ),
                    ],
                  ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(
                CupertinoIcons.doc,
                size: 25.0,
              )
            ],
          ),
        );
  }
}