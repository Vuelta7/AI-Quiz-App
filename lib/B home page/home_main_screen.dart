import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/folder_model_widget.dart';
import 'package:learn_n/util.dart';
import 'package:uuid/uuid.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  _HomeMainScreenState createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    print('Tapped index: $index');
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      print('Opening Drawer');
      _scaffoldKey.currentState?.openDrawer();
    } else if (index == 1) {
      print('Navigating to AddFolderScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddFolderScreen()),
      );
    } else if (index == 2) {
      print('Navigating to NotificationScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: const HomeBody(),
      drawer: const DrawerWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded, size: 50),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded, size: 50),
            label: 'Add Folder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 50),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              border: const Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 4.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo_icon.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn-N',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PressStart2P"),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              print('Settings tapped');
            },
          ),
          ListTile(
            title: const Text(
              'About Us',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              print('About Us tapped');
            },
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

  Future<void> uploadFolderToDb() async {
    try {
      final id = const Uuid().v4();
      await FirebaseFirestore.instance.collection("folders").doc(id).set({
        "folderName": folderNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "creator": FirebaseAuth.instance.currentUser!.uid,
        "questions": {},
        "color": rgbToHex(_selectedColor),
        "position": 0,
      });
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/paper.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
  const HomeBody({super.key});

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Folder',
              hintText: 'Enter folder name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('folders')
              .where('creator',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No data here :<'),
              );
            }

            final filteredFolders = snapshot.data!.docs.where((folderDoc) {
              final folderData = folderDoc.data() as Map<String, dynamic>;
              final folderName = folderData['folderName'] as String;

              return folderName.toLowerCase().contains(searchQuery);
            }).toList();

            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filteredFolders.length,
                itemBuilder: (context, index) {
                  final folderDoc = filteredFolders[index];
                  final folderData = folderDoc.data() as Map<String, dynamic>;

                  return FolderModel(
                    folderId: folderDoc.id,
                    headerColor: hexToColor(folderData['color']),
                    folderName: folderData['folderName'],
                    description: folderData['description'],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
