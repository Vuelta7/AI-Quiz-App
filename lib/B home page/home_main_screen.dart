import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/dashboard%20page/dashboard.dart';
import 'package:learn_n/B%20home%20page/drawer%20page/drawer_contents.dart';
import 'package:learn_n/B%20home%20page/folder%20page/add_folder_screen.dart';
import 'package:learn_n/B%20home%20page/folder%20page/folder_screen.dart';
import 'package:learn_n/B%20home%20page/notification%20page/notification_body.dart';
import 'package:learn_n/B%20home%20page/reels_page/reels_page.dart';

class HomeMainScreen extends StatefulWidget {
  final String userId;

  const HomeMainScreen({super.key, required this.userId});

  @override
  _HomeMainScreenState createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDisposed = false;

  int _selectedIndex = 2;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      if (_isDisposed) return;
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 1) {
      body = Dashboard(userId: widget.userId); // Change to dashboard screen
    } else if (_selectedIndex == 2) {
      body = FolderPage(userId: widget.userId);
    } else if (_selectedIndex == 3) {
      body = ReelsPage(userId: widget.userId);
    } else if (_selectedIndex == 4) {
      body = const NotificationBody();
    } else {
      body = FolderPage(userId: widget.userId);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      drawer: const Drawer(
        child: DrawerContent(),
      ),
      body: body,
      floatingActionButton: _selectedIndex == 2 || _selectedIndex == 0
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
            icon: Icon(Icons.dashboard, size: 50, color: Colors.black),
            label: 'Dashboard',
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
