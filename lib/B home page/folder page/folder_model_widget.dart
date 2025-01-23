import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/B%20home%20page/folder%20page/edit_folder_screen.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_widget.dart';

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
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InsideFolderMain(
                  headerColor: headerColor,
                  folderId: folderId,
                  folderName: folderName,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditFolderWidget(
                                folderId: folderId,
                                initialFolderName: folderName,
                                initialDescription: description,
                                initialColor: headerColor,
                                isImported: isImported, // Pass the value
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 30,
                          color: _getTextColorForBackground(headerColor),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
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
                        icon: Icon(
                          Icons.share_rounded,
                          size: 30,
                          color: _getTextColorForBackground(headerColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }
}
