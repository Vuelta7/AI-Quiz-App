import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/custom_appbar.dart';
import 'package:learn_n/core/widgets/folder_form.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFolderPage extends StatefulWidget {
  final String folderId;
  final String initialFolderName;
  final String initialDescription;
  final Color initialColor;
  final bool isImported;

  const EditFolderPage({
    super.key,
    required this.folderId,
    required this.initialFolderName,
    required this.initialDescription,
    required this.initialColor,
    this.isImported = false,
  });

  @override
  State<EditFolderPage> createState() => _EditFolderPageState();
}

class _EditFolderPageState extends State<EditFolderPage> {
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
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorString = prefs.getString('selectedColor');
    if (colorString != null) {
      setState(() {
        _selectedColor = Color(int.parse(colorString));
      });
    }
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
          icon: Icon(
            Icons.arrow_back_rounded,
            color: getColorForTextAndIcon(widget.initialColor),
          ),
        ),
        color: _selectedColor,
      ),
      backgroundColor: _selectedColor,
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
                onChanged: (String) {},
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Loading(),
            ),
        ],
      ),
    );
  }
}
