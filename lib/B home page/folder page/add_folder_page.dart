import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_appbar.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_form.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key});

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  final folderNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final folderIdController =
      TextEditingController(); // Controller for folder ID
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  bool _isAddingFolder = true; // Track whether adding or importing folder
  final FocusNode descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    folderNameController.dispose();
    descriptionController.dispose();
    folderIdController.dispose();
    descriptionFocusNode.dispose();
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
      appBar: CustomAppBar(
        title: 'Add Folder',
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
                    child: buildFolderForm(
                      context: context,
                      isLoading: _isLoading,
                      isFormValid:
                          folderNameController.text.trim().isNotEmpty &&
                              descriptionController.text.trim().isNotEmpty,
                      folderNameController: folderNameController,
                      descriptionController: descriptionController,
                      selectedColor: _selectedColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      onSave: () async {
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
                          await uploadFolderToDb();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Folder added successfully!'),
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
                      onDelete: () async {
                        // Add your delete logic here
                      },
                      isImported: !_isAddingFolder,
                      folderIdController: folderIdController,
                      onImport: () async {
                        if (folderIdController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a folder ID.'),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await importFolder();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Folder imported successfully!'),
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
                      isAddScreen: true,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(descriptionFocusNode);
                      },
                      descriptionFocusNode: descriptionFocusNode,
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
