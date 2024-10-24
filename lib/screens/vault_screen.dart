import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secure_note/controllers/vault_controller.dart';

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
              ),
              Expanded(
                child: Obx(() {
                  final List<String> vaults = controller.vaultIds;

                  return PageView.builder(
                    itemCount: vaults.length + 1, // don't forget the functional card!
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      if (index < vaults.length) {
                        return VaultCard(vaultName: vaults[index]);
                      } else {
                        return AddNewVaultCard();
                      }
                    },
                  );},
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
                    if (await vaultController.unlockVault(vaultName, password)) {
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
            String vaultName = '';
            String vaultPassword = '';
            return CupertinoAlertDialog(
              title: Text('Create New Vault'),
              content: Column(
                children: [
                  CupertinoTextField(
                    placeholder: 'Vault Name',
                    onChanged: (value) {
                      vaultName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'Password',
                    obscureText: true,
                    onChanged: (value) {
                      vaultPassword = value;
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
                  child: Text('Create'),
                  onPressed: () async {
                    if (vaultName.isNotEmpty && vaultPassword.isNotEmpty) { // input sanitization goes here
                      controller.createVault(vaultName, vaultPassword);
                      Navigator.of(context).pop();
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
