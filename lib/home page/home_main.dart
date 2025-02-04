import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:learn_n/home%20page/dashboard%20page/dashboard_main.dart';
import 'package:learn_n/home%20page/drawer%20page/drawer_contents.dart';
import 'package:learn_n/home%20page/folder%20page/add_folder_page.dart';
import 'package:learn_n/home%20page/folder%20page/folder_page.dart';
import 'package:learn_n/home%20page/notes%20page/notification_body.dart';
import 'package:learn_n/home%20page/reels_page/reels_page.dart';

class HomeMain extends StatefulWidget {
  final String userId;

  const HomeMain({super.key, required this.userId});

  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDisposed = false;
  int _selectedIndex = 2;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(milliseconds: 100),
      () => _borderRadiusAnimationController.forward(),
    );

    _fetchSelectedColor();
  }

  Future<void> _fetchSelectedColor() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _selectedColor =
            hexToColor(userData['selectedColor'] ?? rgbToHex(Colors.blue));
      });
    } else {
      setState(() {
        _selectedColor = Colors.blue;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _borderRadiusAnimationController.dispose();
    _hideBottomBarAnimationController.dispose();
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
    if (_selectedColor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final primaryColor = _selectedColor!;

    Widget body;
    if (_selectedIndex == 1) {
      body = Dashboard(userId: widget.userId, color: _selectedColor!);
    } else if (_selectedIndex == 2) {
      body = FolderPage(userId: widget.userId, color: _selectedColor!);
    } else if (_selectedIndex == 3) {
      body = ReelsPage(userId: widget.userId);
    } else if (_selectedIndex == 4) {
      body = NotificationPage(color: _selectedColor!,);
    } else {
      body = FolderPage(userId: widget.userId, color: _selectedColor!);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
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
                      builder: (context) => const AddFolderPage()),
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
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 5,
        tabBuilder: (int index, bool isActive) {
          final isLightColor = primaryColor.computeLuminance() > 0.5;
          final activeColor = isLightColor ? Colors.black : Colors.white;
          final inactiveColor = isLightColor ? Colors.white : Colors.black;
          final color = isActive ? activeColor : inactiveColor;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                index == 0
                    ? Icons.menu_rounded
                    : index == 1
                        ? Icons.analytics_outlined
                        : index == 2
                            ? Icons.folder
                            : index == 3
                                ? Icons.video_library
                                : Icons.notifications,
                size: 45,
                color: color,
              ),
              Text(
                index == 0
                    ? 'Menu'
                    : index == 1
                        ? 'Dashboard'
                        : index == 2
                            ? 'Folders'
                            : index == 3
                                ? 'Reels'
                                : 'Notifications',
                style: TextStyle(color: color, fontSize: 12),
              )
            ],
          );
        },
        backgroundColor: getShade(primaryColor, 800),
        height: 70,
        activeIndex: _selectedIndex,
        splashColor: Colors.black,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 100,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.none,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: _onItemTapped,
        hideAnimationController: _hideBottomBarAnimationController,
      ),
    );
  }
}
