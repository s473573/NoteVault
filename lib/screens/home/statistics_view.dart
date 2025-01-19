
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/home_controller.dart';
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

    return Container(
      // color: CupertinoColors.systemGrey6,
      padding: const EdgeInsets.all(32.0),
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
  alignment: Alignment.centerLeft,
  onPressed: () {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        String oldPassword = '';
        String newPassword = '';
        String confirmPassword = '';

        return CupertinoAlertDialog(
          title: Text('Change Vault Key'),
          content: Column(
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
            ],
          ),
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
  child: Text('Change Vault Key', textAlign: TextAlign.left),
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
                child: Text(
                  'Destroy Vault',
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}