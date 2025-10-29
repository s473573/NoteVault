import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/login_controller.dart';
import 'package:secure_note/widgets/InputShaker.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final masterPassword = ''.obs;
    final shouldShake = false.obs;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting and Animated Title
              _AnimatedTitle(),
              SizedBox(height: 140),

              // Password Input Section
              Obx(() => ShakeWidget(
                    shouldShake: shouldShake.value,
                    child: Column(
                      children: [
                        CupertinoTextField(
                          textAlign: TextAlign.center,
                          obscureText: true,
                          placeholder: controller.isMasterPasswordSet.value
                              ? 'Provide your master password'
                              : 'Initialize your master password',
                          // placeholderStyle: TextStyle(
                          //   color: CupertinoColors.systemGrey,
                          // ),
                          // padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          // decoration: BoxDecoration(
                          //   color: CupertinoColors.white,
                          //   borderRadius: BorderRadius.circular(30),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: CupertinoColors.systemGrey2,
                          //       blurRadius: 10,
                          //       offset: Offset(0, 4),
                          //     ),
                          //   ],
                          // ),
                          onChanged: (value) =>
                              controller.password.value = value,
                        ),
                        if (controller.passwordError.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: Text(
                              controller.passwordError.value,
                              style: TextStyle(
                                color: CupertinoColors.destructiveRed,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),

              SizedBox(height: 10),

              // FaceID Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  controller.authenticateWithFaceID();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.lock_shield_fill, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Face ID',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 50),

              // Submit Button
              Obx(
                () => CupertinoButton.filled(
                  child: Text(controller.isMasterPasswordSet.value
                      ? 'Login'
                      : 'Set Master Password'),
                  onPressed: () {
                    shouldShake.value = false;
                    controller.handleSubmit();
                    if (controller.passwordError.value.isNotEmpty) {
                      shouldShake.value = true;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated Title Widget
class _AnimatedTitle extends StatefulWidget {
  @override
  State<_AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<_AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    )..addListener(() {
        setState(() {});
      });
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome to your',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
        ),
        SizedBox(height: 5),
        Transform.translate(
          offset: Offset(0, _animation.value * 5), // simple flow animation
          child: Text(
            'NoteVault',
            style:
                CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif', // some serif font goes here
                    ),
          ),
        ),
      ],
    );
  }
}
