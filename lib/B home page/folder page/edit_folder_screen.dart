import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_appbar.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_form.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFolderWidget extends StatefulWidget {
  final String folderId;
  final String initialFolderName;
  final String initialDescription;
  final Color initialColor;
  final bool isImported;

  const EditFolderWidget({
    super.key,
    required this.folderId,
    required this.initialFolderName,
    required this.initialDescription,
    required this.initialColor,
    this.isImported = false,
  });

  @override
  State<EditFolderWidget> createState() => _EditFolderWidgetState();
}

class _EditFolderWidgetState extends State<EditFolderWidget> {
  late TextEditingController folderNameController;
  late TextEditingController descriptionController;
  late Color _selectedColor;
  bool _isLoading = false;
  final FocusNode descriptionFocusNode = FocusNode();

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
    descriptionFocusNode.dispose();
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

  Future<void> removeFolderFromHomeBody() async {
    try {
      final userId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('userId'));
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection("folders")
            .doc(widget.folderId)
            .update({
          "accessUsers": FieldValue.arrayRemove([userId]),
        });
      }
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
      appBar: CustomAppBar(
        title: 'Edit Folder',
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: buildFolderForm(
                context: context,
                isLoading: _isLoading,
                isFormValid: _isFormValid,
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
                onDelete: () async {
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
                isImported: widget.isImported,
                onImport: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await removeFolderFromHomeBody();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Folder removed successfully!'),
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
                folderIdController: null,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(descriptionFocusNode);
                },
                descriptionFocusNode: descriptionFocusNode,
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
