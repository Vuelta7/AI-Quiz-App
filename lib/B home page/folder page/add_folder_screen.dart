import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/home_page_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFolderScreen extends StatefulWidget {
  const AddFolderScreen({super.key});

  @override
  State<AddFolderScreen> createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final folderNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final folderIdController =
      TextEditingController(); // Controller for folder ID
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  bool _isAddingFolder = true; // Track whether adding or importing folder

  @override
  void dispose() {
    folderNameController.dispose();
    descriptionController.dispose();
    folderIdController.dispose();
    super.dispose();
  }

  Future<String> _generateUnique4DigitCode() async {
    final random = Random();
    String code = '';
    bool exists = true;

    while (exists) {
      code = (1000 + random.nextInt(9000)).toString();
      final doc = await FirebaseFirestore.instance
          .collection("folders")
          .doc(code)
          .get();
      if (!doc.exists) {
        exists = false;
      }
    }

    return code;
  }

  Future<void> uploadFolderToDb() async {
    try {
      final id = await _generateUnique4DigitCode();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await FirebaseFirestore.instance.collection("folders").doc(id).set({
          "folderName": folderNameController.text.trim(),
          "description": descriptionController.text.trim(),
          "creator": userId,
          "color": rgbToHex(_selectedColor),
          "accessUsers": [],
        });
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> importFolder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection("folders")
            .doc(folderIdController.text.trim())
            .update({
          "accessUsers": FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Folder',
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
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAddingFolder = true;
                        });
                      },
                      child: Container(
                        color: _isAddingFolder ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Add Folder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _isAddingFolder ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAddingFolder = false;
                        });
                      },
                      child: Container(
                        color: !_isAddingFolder ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Import Folder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                !_isAddingFolder ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        if (_isAddingFolder) ...[
                          TextFormField(
                            controller: folderNameController,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              hintText: 'Folder Name',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: descriptionController,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                            ),
                            maxLines: 3,
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
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (folderNameController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a folder name.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (descriptionController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a description.'),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await uploadFolderToDb();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Folder added successfully!'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ] else ...[
                          TextFormField(
                            controller: folderIdController,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              hintText: 'Folder ID',
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (folderIdController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please enter a folder ID.'),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await importFolder();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Folder imported successfully!'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'IMPORT',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
