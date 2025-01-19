// home_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:secure_note/controllers/home_controller.dart';
import 'package:secure_note/data/models/note.dart';
import 'package:secure_note/widgets/dialogs/dialog_utils.dart';

import 'statistics_view.dart';
import 'widgets/note_card.dart';

// add max length to a note card, so notes would not be even in height.

class HomeScreen extends StatefulWidget {
  final HomeController controller = Get.find<HomeController>();

  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find();
  late Future<void> _initVaultFuture;
  late String vaultName;
  late String inputPassword;

  @override
  void initState() {
    super.initState();
    // Retrieve arguments: [vaultName, password]
    vaultName = Get.arguments[0];
    inputPassword = Get.arguments[1];
    // Wrap into a private widget to reduce clutter
    _initVaultFuture = controller.initVault(vaultName, inputPassword);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(controller.name.value),
      ),
      child: FutureBuilder<void>(
        future: _initVaultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          } else if (snapshot.hasError) {
            print("Building error view...");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showErrorDialog(
                context,
                'The password you entered is incorrect. Unable to decrypt the vault.',
              ).then((_) => Get.back());
            });
            return _buildErrorView();
          } else {
            print("Building vault view...");
            return _buildMainContent(vaultName);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CupertinoActivityIndicator(radius: 20.0),
    );
  }
  Widget _buildErrorView() {
    // Possibly show a scaffold with a minimal UI or a background
    // to avoid “empty screen” confusion
    return Center(
      child: Text(
        "Unable to unlock the vault.",
        style: TextStyle(
          color: CupertinoColors.destructiveRed,
          fontSize: 18.0,
        ),
      ),
    );
  }
  Widget _buildMainContent(String vaultName) {
    return Stack(
      children: [
        // Normal content
        _buildNoteGrid(),
    
        // Dim background (overlay)
        _buildDimmedOverlay(),
        // Slide in overlay
        _buildStatisticsOverlay(vaultName),
      ],
    );
  }

  Widget _buildNoteGrid() {
    return SafeArea(
      child: Column(
        children: [
          CupertinoNavigationBar(
            leading: Text(
              'My Secure Notes',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            trailing: GestureDetector(
              onTap: () {
                controller.toggleStatistics();
                print("Circle Avatar was clicked!");
              },
              child: CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('assets/images/no-image-yet.png'),
              ),
            ),
            border: Border(
              bottom: BorderSide(width: 0.0, color: Colors.transparent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() {
                return GridView.builder(
                  itemCount: controller.noteCollection.length,
                  // Grid configuration
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Max two columns
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final Note note = controller.noteCollection[index];
                    return NoteCardWidget(note: note);
                  },
                );
              }),
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: CupertinoColors.darkBackgroundGray,
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.add,
                  size: 35,
                ),
                onPressed: () {
                  Get.toNamed('/create_note');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDimmedOverlay() {
    return Obx(() {
      return controller.isStatisticsVisible.value
          ? GestureDetector(
              onTap: () => controller.toggleStatistics(),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            )
          : SizedBox.shrink();
    });
  }
  Widget _buildStatisticsOverlay(String vaultName) {
    return Obx(() {
      final screenWidth = MediaQuery.of(context).size.width;
      return AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: controller.isStatisticsVisible.value
            ? screenWidth * 0.3
            : screenWidth,
        top: 0,
        bottom: 0,
        child: Container(
          width: screenWidth * 0.7,
          child: StatisticsView(
            vaultName: vaultName,
            onClose: () => controller.toggleStatistics(),
          ),
        ),
      );
    });
  }
}