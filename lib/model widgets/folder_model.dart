import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_main_widget.dart';
import 'package:learn_n/model%20widgets/edit_folder_widget.dart';

class FolderModel extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String description;
  final Color headerColor;

  const FolderModel({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.description,
    this.headerColor = const Color(0xFFBDBDBD),
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
                builder: (context) => InsideFolderMain(folderId: folderId),
              ),
            );
          },
          child: Container(
            width: 310,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                width: 4,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: headerColor,
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        folderName,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.star_border_rounded),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditFolderWidget(
                                    folderId: folderId, // Pass the folderId
                                    initialFolderName:
                                        folderName, // Pass current folder name
                                    initialDescription:
                                        description, // Pass current description
                                    initialColor:
                                        headerColor, // Pass current header color
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              size: 40,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
