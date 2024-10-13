import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/animation.dart';

class NoteController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<Offset> slideAnimation;
  
  Map<String, RxBool> notesExpanded = {};
  final slideDur = const Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(
      vsync: this,
      duration: slideDur,
    );
    

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, 0.3),
    ).animate(CurvedAnimation(parent: animController, curve: Curves.fastOutSlowIn));

    print("NOTE CONTROLLER INITIALIZED");
  }
  
  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}