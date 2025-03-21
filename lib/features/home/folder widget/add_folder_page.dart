import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/widgets/custom_appbar.dart';
import 'package:learn_n/core/widgets/folder_form.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key});

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  final folderNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final folderIdController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  bool _isAddingFolder = true;
  final FocusNode descriptionFocusNode = FocusNode();

  bool get isFormValid {
    return folderNameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
  }

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

  Future<void> _loadSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorString =
        prefs.getString('selectedColor') ?? rgbToHex(Colors.blue);
    setState(() {
      _selectedColor = hexToColor(colorString);
    });
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
            color: Colors.white,
          ),
        ),
        color: _selectedColor,
      ),
      backgroundColor: Colors.white,
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
                        color: _isAddingFolder
                            ? getShade(_selectedColor, 600)
                            : Colors.white,
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
                        color: !_isAddingFolder
                            ? getShade(_selectedColor, 600)
                            : Colors.white,
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
                    child: _isAddingFolder
                        ? buildFolderForm(
                            context: context,
                            isLoading: _isLoading,
                            isFormValid: isFormValid,
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
                                    content:
                                        Text('Please enter a folder name.'),
                                  ),
                                );
                                return;
                              }
                              if (descriptionController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter a description.'),
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
                            isImported: false,
                            folderIdController: folderIdController,
                            onImport: () async {},
                            isAddScreen: true,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(descriptionFocusNode);
                              setState(() {});
                            },
                            descriptionFocusNode: descriptionFocusNode,
                            onChanged: (value) {
                              setState(() {});
                            },
                          )
                        : buildFolderForm(
                            context: context,
                            isLoading: _isLoading,
                            isFormValid:
                                folderIdController.text.trim().isNotEmpty,
                            folderNameController: folderNameController,
                            descriptionController: descriptionController,
                            selectedColor: _selectedColor,
                            onColorChanged: (Color color) {},
                            onSave: () async {},
                            isImported: true,
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
                                    content:
                                        Text('Folder imported successfully!'),
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
                            isAddScreen: false,
                            onFieldSubmitted: (_) {},
                            descriptionFocusNode: descriptionFocusNode,
                            onChanged: (value) {
                              setState(() {}); // Update form validation state
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) const Loading(),
        ],
      ),
    );
  }
}
