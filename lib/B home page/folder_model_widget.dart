import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_widget.dart';
import 'package:learn_n/util.dart';

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
                builder: (context) => InsideFolderMain(
                  folderId: folderId,
                  folderName: folderName,
                ),
              ),
            );
          },
          child: Container(
            width: 310,
            margin: const EdgeInsets.only(top: 20), // For tab overlap
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                width: 2,
                color: headerColor
                    .withOpacity(0.8), // Make border same as the background
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
                // Folder Content Section
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

                // Action Button to Edit Folder
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFolderWidget(
                            folderId: folderId,
                            initialFolderName: folderName,
                            initialDescription: description,
                            initialColor: headerColor,
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
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Function to determine appropriate text color based on background color
  Color _getTextColorForBackground(Color backgroundColor) {
    // If background color is dark, return light text color and vice versa
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }
}

class EditFolderWidget extends StatefulWidget {
  final String folderId;
  final String initialFolderName;
  final String initialDescription;
  final Color initialColor;

  const EditFolderWidget({
    super.key,
    required this.folderId,
    required this.initialFolderName,
    required this.initialDescription,
    required this.initialColor,
  });

  @override
  State<EditFolderWidget> createState() => _EditFolderWidgetState();
}

class _EditFolderWidgetState extends State<EditFolderWidget> {
  late TextEditingController folderNameController;
  late TextEditingController descriptionController;
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    folderNameController =
        TextEditingController(text: widget.initialFolderName);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    folderNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> editFolderToDb() async {
    try {
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .update({
        "folderName": folderNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "color": rgbToHex(_selectedColor),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteFolderFromDb() async {
    try {
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  bool get _isFormValid {
    return folderNameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Folder',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: folderNameController,
                    decoration: const InputDecoration(
                      hintText: 'Folder Name',
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  ColorPicker(
                    pickersEnabled: const {
                      ColorPickerType.wheel: true,
                    },
                    color: _selectedColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    heading: const Text('Select color'),
                    subheading: const Text('Select a different shade'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading || !_isFormValid
                        ? null
                        : () async {
                            if (folderNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a folder name.'),
                                ),
                              );
                              return;
                            }
                            if (descriptionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a description.'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await editFolderToDb();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Folder updated successfully!'),
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid ? Colors.black : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading || !_isFormValid
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await deleteFolderFromDb();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Folder deleted successfully!'),
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid ? Colors.black : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Delete Folder',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
