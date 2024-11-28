import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/drawer_widget.dart';
import 'package:learn_n/model%20widgets/folder_model.dart';
import 'package:learn_n/util.dart';

import 'add_folder_screen.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  _HomeMainScreenState createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Add a variable for the bottom navigation index
  int _selectedIndex = 0;

  // Method to change the selected index when a button in the bottom navigation is tapped
  void _onItemTapped(int index) {
    if (index == 0) {
      // Open drawer if "Menu" is tapped
      _scaffoldKey.currentState?.openDrawer();
    } else if (index == 1) {
      // Navigate to Add Folder Screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const AddFolderScreen()), // Ensure you have AddFolderScreen defined
      );
    } else if (index == 2) {
      // Handle notifications (this could trigger a dialog, etc.)
      print('Notifications tapped');
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset:
          true, // Optional: to adjust when the keyboard appears
      body: const HomeBody(), // Keep the body as is
      drawer: const DrawerWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded, size: 30),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded, size: 40),
            label: 'Add Folder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 30),
            label: 'Notifications',
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

        // StreamBuilder for getting folders
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

            // Filter the folders based on the search query
            final filteredFolders = snapshot.data!.docs.where((folderDoc) {
              final folderData = folderDoc.data() as Map<String, dynamic>;
              final folderName = folderData['folderName'] as String;

              // Check if the folder name contains the search query
              return folderName.toLowerCase().contains(searchQuery);
            }).toList();

            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets
                    .zero, // Remove any padding/margin around the ListView
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
    // Dispose of the controller when the widget is disposed
    _searchController.dispose();
    super.dispose();
  }
}
