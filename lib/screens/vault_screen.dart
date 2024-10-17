import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VaultScreen extends StatelessWidget {
  final List<String> vaults = ["Work Vault", "Personal Vault", "Ideas Vault"]; // ad-hoc vaults

  VaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CupertinoNavigationBar(
              leading: Text(
                'Your Vaults',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: vaults.length + 1, // don't forget the functional card!
                controller: PageController(viewportFraction: 0.85),
                itemBuilder: (context, index) {
                  if (index < vaults.length) {
                    return VaultCard(vaultName: vaults[index]);
                  } else {
                    return AddNewVaultCard();
                  }
                },
              ),
            ),
          ],
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
        Get.toNamed('/vault', arguments: vaultName);
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // should add a new very much secure vault to the db or smt
        Get.toNamed('/create_vault');
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
