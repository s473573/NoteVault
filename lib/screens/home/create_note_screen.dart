import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/create_note_controller.dart';

// TODO: make saving work without hitting the save button;
// might get rid of the button alltogether

class CreateNoteScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final CreateNoteController _createController = Get.find();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Write a note'),
        trailing: Container(
          child: CupertinoButton(
            padding: const EdgeInsets.all(8.0),
            onPressed: () {
              _createController.saveNote(
                  nameController.text,
                  contentController.text
                );
              Get.back();
            },
            child: Icon(
              CupertinoIcons.check_mark,
              size: 24,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CupertinoTextField(
                  textAlign: TextAlign.center,
                  controller: nameController,
                  placeholder: 'Note Name',
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(), // do i need this at all?
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: CupertinoTextField(
                  minLines: 16,
                  maxLines: null,
                  //expands: true,
                  controller: contentController,
                  placeholder: 'Type your note here...',
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoTheme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 16.0,)
            ],
          ),
        ),
      ),
    );
  }
}
