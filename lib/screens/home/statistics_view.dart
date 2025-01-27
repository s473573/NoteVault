
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/home_controller.dart';
import 'package:secure_note/utils/vault_input_validation.dart';
import 'package:secure_note/widgets/InputShaker.dart';
import 'package:secure_note/widgets/dialogs/dialog_utils.dart';

///
/// Change those ugly buttons!
///
class StatisticsView extends StatelessWidget {
  final String vaultName;
  final VoidCallback onClose;

  const StatisticsView({required this.vaultName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    var shouldShake = false.obs;

    return Container(
      // color: CupertinoColors.systemGrey6,
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vault Control',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onClose,
                child: Icon(CupertinoIcons.clear),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Body
          Text('Vault Name: $vaultName'),
          Text(
            'Date Created: '
            '${controller.getVaultCreationDate(vaultName)}',
          ),
          Text('Number of Notes: ${controller.noteCollection.length}'),
          Spacer(),
          // Footer buttons
          Column(
            children: [
              CupertinoButton.filled(
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String oldPassword = '';
                      String newPassword = '';
                      String confirmPassword = '';

                      return CupertinoAlertDialog(
                        title: Text('Change Vault Key'),
                        content: (Obx(() => ShakeWidget(
                              shouldShake: shouldShake.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  CupertinoTextField(
                                    placeholder: 'Old Password',
                                    obscureText: true,
                                    onChanged: (value) {
                                      oldPassword = value;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  CupertinoTextField(
                                    placeholder: 'New Password',
                                    obscureText: true,
                                    onChanged: (value) {
                                      newPassword = value;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  CupertinoTextField(
                                    placeholder: 'Confirm New Password',
                                    obscureText: true,
                                    onChanged: (value) {
                                      confirmPassword = value;
                                    },
                                  ),
                                  if (controller.passwordError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 8.0),
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
                            ))),
                        actions: [
                          CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without changes
              },
            ),
            CupertinoDialogAction(
              child: Text('Change'),
              isDefaultAction: true,
              onPressed: () async {
                if (newPassword != confirmPassword) {
                  showErrorDialog(context, 'Passwords do not match!');
                  return;
                }
                
                final error = VaultInputValidator.validatePassword(newPassword);
                if (error != null)
                { controller.passwordError.value = error; shouldShake.value = true; return; }

                try {
                  await controller.changePassword(
                    oldPassword,
                    newPassword,
                  );
                  showSuccessDialog(context, 'Password successfully changed!')
                      .then((_) => Get.offAllNamed('/'));
                } catch (e) {
                  showErrorDialog(context, e.toString());
                }
              },
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text('Relock ', style: TextStyle(fontWeight: FontWeight.bold),),
      Icon(CupertinoIcons.lock_circle)
    ],
  ),
),
              SizedBox(height: 16),
              CupertinoButton.filled(
                alignment: Alignment.centerLeft,
                onPressed: () {
                  // Vault confirmation dialog
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Vault Removal'),
                        content: Text(
                          "All of your notes would be lost!",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('Confirm'),
                            isDestructiveAction: true,
                            onPressed: () async {
                              // remove this vault from collection
                              // and return to title screen
                              controller.removeVault();
                              Get.offAllNamed('/');
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Destroy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(CupertinoIcons.delete_solid)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}