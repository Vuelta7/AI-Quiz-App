import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/features/home/folder%20widget/edit_folder_page.dart';
import 'package:learn_n/features/infolder/infolder_main.dart';

class FolderModelKen extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String description;
  final Color headerColor;
  final bool isImported;
  final String userId;

  const FolderModelKen({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.description,
    this.headerColor = const Color(0xFFBDBDBD),
    required this.isImported,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InFolderMain(
              headerColor: headerColor,
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
                color: headerColor,
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
                        color: headerColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: headerColor,
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
                      color: headerColor,
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
                              initialColor: headerColor,
                              isImported: isImported,
                            ),
                          ),
                        );
                      } else if (value == 'Delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: headerColor,
                              title: const Text(
                                'Confirm Deletion',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this folder?',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
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
                                              FieldValue.arrayRemove([
                                            /* Add logic to get the current user's ID */
                                          ]),
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'You have been removed from the folder access list.'),
                                          ),
                                        );
                                      } else {
                                        await FirebaseFirestore.instance
                                            .collection("folders")
                                            .doc(folderId)
                                            .delete();
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
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
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
                              backgroundColor: headerColor,
                              title: const Text(
                                'Share Folder',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Share this Folder ID with your friend. They can use it to add this folder to their account.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    folderId,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
                                      backgroundColor:
                                          headerColor.withOpacity(0.8),
                                    ),
                                    child: const Text('Copy Folder ID'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'Edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Edit Folder'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Folder'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Share',
                        child: Row(
                          children: const [
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
