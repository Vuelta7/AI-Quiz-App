import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/drawer_contents.dart';
import 'package:learn_n/B%20home%20page/folder_model_widget.dart';
import 'package:learn_n/B%20home%20page/notification_body.dart';
import 'package:learn_n/B%20home%20page/reels_page.dart';
import 'package:learn_n/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMainScreen extends StatefulWidget {
  final String userId;

  const HomeMainScreen({super.key, required this.userId});

  @override
  _HomeMainScreenState createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDisposed = false; // Add this flag

  int _selectedIndex = 0;

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true when disposing
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      if (_isDisposed) return; // Check if the widget is disposed
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 1) {
      body = HomeBody(userId: widget.userId);
    } else if (_selectedIndex == 2) {
      body = ReelsPage(userId: widget.userId);
    } else if (_selectedIndex == 3) {
      body = const NotificationBody();
    } else {
      body = HomeBody(userId: widget.userId);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      drawer: const Drawer(
        child: DrawerContent(),
      ),
      body: body,
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFolderScreen()),
                );
              },
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 30,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded, size: 50, color: Colors.black),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 50, color: Colors.black),
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library, size: 50, color: Colors.black),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 50, color: Colors.black),
            label: 'Notifications',
          ),
        ],
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
          "position": 0,
          "accessUsers": [],
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
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

class HomeBody extends StatefulWidget {
  final String userId;

  const HomeBody({super.key, required this.userId});

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _folders = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
  }

  void _updateSearchQuery() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _folders.removeAt(oldIndex);
      _folders.insert(newIndex, item);
    });
  }

  List<DocumentSnapshot> _filterFolders(List<DocumentSnapshot> docs) {
    return docs.where((folderDoc) {
      final folderData = folderDoc.data() as Map<String, dynamic>;
      final folderName = folderData['folderName'] as String;
      return folderName.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: TextField(
            controller: _searchController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'Search Folder',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('folders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    'No Folder here 🗂️\nCreate one by clicking the Add Folder ➕.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            _folders = _filterFolders(snapshot.data!.docs.where((folderDoc) {
              final folderData = folderDoc.data() as Map<String, dynamic>;
              final accessUsers = List<String>.from(folderData['accessUsers']);
              return folderData['creator'] == widget.userId ||
                  accessUsers.contains(widget.userId);
            }).toList());

            return Expanded(
              child: ReorderableListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _folders.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final folderDoc = _folders[index];
                  final folderData = folderDoc.data() as Map<String, dynamic>;
                  final isImported =
                      List<String>.from(folderData['accessUsers'])
                          .contains(widget.userId);

                  return ListTile(
                    key: ValueKey(folderDoc.id),
                    title: FolderModel(
                      folderId: folderDoc.id,
                      headerColor: hexToColor(folderData['color']),
                      folderName: folderData['folderName'],
                      description: folderData['description'],
                      isImported: isImported, // Set the value
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
