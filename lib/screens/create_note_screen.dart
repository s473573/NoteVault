import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/create_note_controller.dart';

class CreateNoteScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final CreateNoteController _createController = Get.find();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Write a note'),
        // padding: const EdgeInsetsDirectional.only(bottom: 8.0),
        trailing: Container(
          child: CupertinoButton(
            padding: const EdgeInsets.all(8.0),
            onPressed: () {
              _createController.saveNote(
                  nameController.text,
                  contentController.text
                );
              Get.back(); // Navigate back after saving
            },
            child: const Text(
              'Save',
              style: TextStyle(color: CupertinoColors.systemIndigo, fontSize: 16),),
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
                    border: Border.all(color: CupertinoColors.systemIndigo),
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
                    border: Border.all(color: CupertinoColors.systemIndigo),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(fontSize: 16.0), // Adjust text size as needed
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
