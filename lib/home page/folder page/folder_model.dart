import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/home%20page/folder%20page/edit_folder_page.dart';
import 'package:learn_n/infolder%20page/infolder_main.dart';

class FolderModel extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String description;
  final Color headerColor;
  final bool isImported;

  const FolderModel({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.description,
    this.headerColor = const Color(0xFFBDBDBD),
    required this.isImported,
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
      child: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            width: 2,
            color: headerColor.withOpacity(0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 8),
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
                      color: _getTextColorForBackground(headerColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getTextColorForBackground(headerColor)
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
                      button.localToGlobal(button.size.bottomRight(Offset.zero),
                          ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero),
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
                              color: _getTextColorForBackground(headerColor)),
                          child: const Text('Edit Folder'),
                          onPressed: () {
                            Navigator.pop(context);
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
                          leadingIcon: Icon(Icons.share,
                              color: _getTextColorForBackground(headerColor)),
                          child: const Text('Share Folder'),
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Share Folder'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Share this Folder ID with your friend. They can use it to add this folder to their account.',
                                      ),
                                      const SizedBox(height: 10),
                                      SelectableText(
                                        folderId,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
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
                                        child: const Text('Copy Folder ID'),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
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
                  color: _getTextColorForBackground(headerColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }
}
