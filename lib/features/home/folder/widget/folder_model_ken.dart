import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/features/home/folder/page/edit_folder_page.dart';
import 'package:learn_n/features/home/folder/provider/folder_provider.dart';
import 'package:learn_n/features/infolder/infolder_main.dart';

class FolderModelKen extends ConsumerWidget {
  final String folderId;
  final String folderName;
  final String description;
  final Color folderColor;
  final bool isImported;
  final String userId;

  const FolderModelKen({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.description,
    this.folderColor = const Color(0xFFBDBDBD),
    required this.isImported,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = getColorForTextAndIcon(folderColor);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InFolderMain(
              color: folderColor,
              folderId: folderId,
              folderName: folderName,
              isImported: isImported,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: folderColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      folderName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: folderColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: folderColor,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 5,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.arrow_drop_down_sharp,
                      size: 40,
                      color: folderColor,
                    ),
                    onSelected: (value) {
                      if (value == 'Edit') {
                        if (isImported) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'This folder is imported. Only the creator can edit it.'),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditFolderPage(
                              folderId: folderId,
                              initialFolderName: folderName,
                              initialDescription: description,
                              initialColor: folderColor,
                              isImported: isImported,
                            ),
                          ),
                        );
                      } else if (value == 'Delete') {
                        final bool isRedBackground =
                            isColorCloseToRed(folderColor);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: folderColor,
                              title: Text(
                                'Confirm Deletion',
                                style: TextStyle(color: textColor),
                              ),
                              content: Text(
                                'Are you sure you want to delete this folder?',
                                style: TextStyle(color: textColor),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    try {
                                      if (isImported) {
                                        await FirebaseFirestore.instance
                                            .collection("folders")
                                            .doc(folderId)
                                            .update({
                                          "accessUsers":
                                              FieldValue.arrayRemove([userId]),
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'You have been removed from the folder access list.'),
                                          ),
                                        );
                                      } else {
                                        final folderController = ref.read(
                                            folderControllerProvider.notifier);
                                        await folderController
                                            .deleteFolderWithSubcollections(
                                                folderId);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Folder deleted successfully!'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: isRedBackground
                                          ? textColor
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (value == 'Share') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: folderColor,
                              title: Text(
                                'Share Folder',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Share this Folder ID with your friend. They can use it to add this folder to their account.',
                                    style: TextStyle(color: textColor),
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    folderId,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'PressStart2P',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: folderId));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Folder ID copied to clipboard!'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: folderColor,
                                    ),
                                    child: Text('Copy Folder ID',
                                        style: TextStyle(color: textColor)),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close',
                                      style: TextStyle(color: textColor)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'Edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Edit Folder'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Folder'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Share Folder'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
