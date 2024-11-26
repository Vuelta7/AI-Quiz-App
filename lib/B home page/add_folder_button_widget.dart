import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddFolderButtonWidget extends StatelessWidget {
  const AddFolderButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddFolderScreen();
          },
        );
      },
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.hexagon_rounded,
            size: 80,
            color: Colors.black,
          ),
          Icon(
            Icons.add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descriptionText;
  const TaskCard({
    super.key,
    required this.color,
    required this.headerText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
        left: 15,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 25),
              child: Text(
                descriptionText,
                style: const TextStyle(fontSize: 14),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFolderScreen extends StatefulWidget {
  const AddFolderScreen({super.key});

  @override
  State<AddFolderScreen> createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final folderNameController = TextEditingController();
  final descriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  @override
  void dispose() {
    folderNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String rgbToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Future<void> uploadTaskToDb() async {
    try {
      final id = const Uuid().v4();
      await FirebaseFirestore.instance.collection("folders").doc(id).set({
        "folderName": folderNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "creator": FirebaseAuth.instance.currentUser!.uid,
        "questions": {},
        "color": rgbToHex(_selectedColor),
      });
    } catch (e) {
      print(e);
      throw e;
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
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
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
                              await uploadTaskToDb();
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
