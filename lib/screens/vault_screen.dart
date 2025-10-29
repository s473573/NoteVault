import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/vault_controller.dart';
import 'package:secure_note/widgets/InputShaker.dart';

// design a storage solution for all of this
// encrypt it with a vault key

// TODO: refactor controller usage
class VaultScreen extends StatelessWidget {
  final VaultController controller = Get.find<VaultController>();

  VaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              CupertinoNavigationBar(
                leading: Text(
                  'Your Vaults',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.home,
                    size: 28,
                  ),
                  onPressed: () {
                    Get.offNamed('/');
                  },
                ),
              ),
              Expanded(
                child: Obx(
                  () {
                    final List<String> vaults = controller.vaultNames;

                    return PageView.builder(
                      itemCount: vaults.length +
                          1, // don't forget the functional card!
                      controller: PageController(viewportFraction: 0.85),
                      itemBuilder: (context, index) {
                        if (index < vaults.length) {
                          final vaultName = vaults[index];
                          var password = '';
                          return Dismissible(
                            key: ValueKey(vaultName),
                            direction: DismissDirection.up,
                            background: Container(
                              alignment: Alignment.center,
                              color: CupertinoColors.systemRed,
                              child: Icon(CupertinoIcons.trash,
                                  color: CupertinoColors.white, size: 40),
                            ),
                            confirmDismiss: (direction) async {
                              return await showCupertinoDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: Text('Confirm vault destruction:'),
                                    content: Column(
                                      children: [
                                        SizedBox(height: 8),
                                        CupertinoTextField(
                                          placeholder: 'Your password',
                                          obscureText: true,
                                          onChanged: (value) {
                                            password = value;
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              false); // Dismiss without deleting
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text('Confirm'),
                                        isDestructiveAction: true,
                                        onPressed: () async {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              final vaultController =
                                  Get.find<VaultController>();
                              vaultController.deleteVault(vaultName, password);
                            },
                            child: VaultCard(vaultName: vaultName),
                          );
                        } else {
                          return AddNewVaultCard();
                        }
                      },
                    );
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

class VaultCard extends StatelessWidget {
  final String vaultName;

  VaultCard({required this.vaultName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // User has to enter a password somewhere here
        // Get.toNamed('/vault', arguments: vaultName);
        showCupertinoDialog(
          context: context,
          builder: (context) {
            String password = '';
            return CupertinoAlertDialog(
              title: Text('Enter Password'),
              content: Column(
                children: [
                  CupertinoTextField(
                    placeholder: 'Password',
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Unlock'),
                  onPressed: () async {
                    final vaultController = Get.find<VaultController>();
                    if (await vaultController.unlockVault(
                        vaultName, password)) {
                      Navigator.of(context).pop();
                      Get.toNamed('/vault', arguments: [vaultName, password]);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.darkBackgroundGray,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vaultName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Icon(
                CupertinoIcons.lock_shield_fill,
                size: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNewVaultCard extends StatelessWidget {
  final VaultController controller = Get.find<VaultController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            // local states
            final vaultName = ''.obs;
            final vaultPassword = ''.obs;

            final shouldShake = false.obs;

            return CupertinoAlertDialog(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Vault Creation'),
              ),
              content: Column(
                children: [
                  // Wrap each input field in ShakeWidget
                  Obx(() => ShakeWidget(
                        shouldShake: shouldShake.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField(
                              placeholder: 'Vault Name',
                              onChanged: (value) => vaultName.value = value,
                            ),
                            if (controller.vaultNameError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 8.0),
                                child: Text(
                                  controller.vaultNameError.value,
                                  style: TextStyle(
                                    color: CupertinoColors.destructiveRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )),
                  SizedBox(height: 16),

                  Obx(() => ShakeWidget(
                        shouldShake: shouldShake.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField(
                              placeholder: 'Password',
                              obscureText: true,
                              onChanged: (value) => vaultPassword.value = value,
                            ),
                            if (controller.passwordError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 8.0),
                                child: Text(
                                  controller.passwordError.value,
                                  style: TextStyle(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Create'),
                  onPressed: () async {
                    controller.vaultNameError.value = '';
                    controller.passwordError.value = '';

                    // attempt to create with raw input
                    final success = await controller.createVaultIfValid(
                      vaultName.value.trim(),
                      vaultPassword.value,
                    );

                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      // trigger the animation
                      shouldShake.value = true;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.darkBackgroundGray,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.add_circled_solid,
            size: 70,
          ),
        ),
      ),
    );
  }
}

// class AddNewVaultCard extends StatelessWidget {
//   final VaultController controller = Get.find<VaultController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showCupertinoDialog(
//           context: context,
//           builder: (context) {
//             String vaultName = '';
//             String vaultPassword = '';
//             return CupertinoAlertDialog(
//               title: Text('Create New Vault'),
//               content: Column(
//                 children: [
//                   CupertinoTextField(
//                     placeholder: 'Vault Name',
//                     onChanged: (value) {
//                       vaultName = value;
//                     },
//                   ),
//                   SizedBox(height: 16),
//                   CupertinoTextField(
//                     placeholder: 'Password',
//                     obscureText: true,
//                     onChanged: (value) {
//                       vaultPassword = value;
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 CupertinoDialogAction(
//                   child: Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 CupertinoDialogAction(
//                   child: Text('Create'),
//                   onPressed: () async {
//                     if (vaultName.isNotEmpty && vaultPassword.isNotEmpty) { // input sanitization goes here
//                       controller.createVault(vaultName, vaultPassword);
//                       Navigator.of(context).pop();
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: CupertinoColors.darkBackgroundGray,
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Icon(
//             CupertinoIcons.add_circled_solid,
//             size: 70,
//           ),
//         ),
//       ),
//     );
//   }
// }
