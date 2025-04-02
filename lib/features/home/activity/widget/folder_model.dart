import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/home/folder/page/edit_folder_page.dart';
import 'package:learn_n/features/infolder/infolder_main.dart';

class FolderModel extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String description;
  final Color headerColor;
  final bool isImported;
  final String userId;
  final bool? isActivity;

  const FolderModel({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.description,
    this.headerColor = const Color(0xFFBDBDBD),
    required this.isImported,
    required this.userId,
    this.isActivity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InFolderMain(
              color: headerColor,
              folderId: folderId,
              folderName: folderName,
              isImported: isImported,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            width: 2,
            color: const Color.fromARGB(34, 0, 0, 0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(34, 0, 0, 0),
              offset: Offset(0, 8),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folderName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: getColorForTextAndIcon(headerColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: getColorForTextAndIcon(headerColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (isActivity == true)
              const SizedBox(height: 40)
            else
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final RenderBox overlay = Overlay.of(context)
                        .context
                        .findRenderObject() as RenderBox;
                    final RelativeRect position = RelativeRect.fromRect(
                      Rect.fromPoints(
                        button.localToGlobal(
                            button.size.bottomRight(Offset.zero),
                            ancestor: overlay),
                        button.localToGlobal(
                            button.size.bottomRight(Offset.zero),
                            ancestor: overlay),
                      ),
                      Offset.zero & overlay.size,
                    );

                    showMenu(
                      context: context,
                      position: position,
                      items: [
                        PopupMenuItem(
                          child: MenuItemButton(
                            leadingIcon: Icon(Icons.edit,
                                color: getColorForTextAndIcon(headerColor)),
                            child: const Text('Edit Folder'),
                            onPressed: () {
                              Navigator.pop(context);
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
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: MenuItemButton(
                            leadingIcon: Icon(Icons.delete,
                                color: getColorForTextAndIcon(headerColor)),
                            child: const Text('Delete Folder'),
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: headerColor,
                                    title: const Text(
                                      'Confirm Deletion',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this folder?',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
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
                                              SnackBar(
                                                  content: Text('Error: $e')),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: MenuItemButton(
                            leadingIcon: Icon(Icons.share,
                                color: getColorForTextAndIcon(headerColor)),
                            child: const Text('Share Folder'),
                            onPressed: () {
                              Navigator.pop(context);
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
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
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
                                        buildRetroButton(
                                          'Copy Folder ID',
                                          getShade(headerColor, 300),
                                          () {
                                            Clipboard.setData(
                                              ClipboardData(text: folderId),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Folder ID copied to clipboard!',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 30,
                    color: getColorForTextAndIcon(headerColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
