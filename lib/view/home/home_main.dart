import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/model/user_color_provider.dart';
import 'package:learn_n/view/home/drawer%20widget/drawer_contents.dart';
import 'package:learn_n/view/home/folder%20widget/add_folder_page.dart';
import 'package:learn_n/view/home/home%20pages/folder_page.dart';
import 'package:learn_n/view/home/home%20pages/store_page.dart';
import 'package:learn_n/view/home/home%20pages/streak_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMain extends StatefulWidget {
  final String userId;

  const HomeMain({super.key, required this.userId});

  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
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
  }

  Future<void> _loadSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? colorHex = prefs.getString('selectedColor');
    setState(() {
      _selectedColor = colorHex != null ? hexToColor(colorHex) : Colors.blue;
    });
  }

  @override
  void dispose() {
    _borderRadiusAnimationController.dispose();
    _hideBottomBarAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = _selectedColor ?? Colors.blue;

    Widget body;
    if (_selectedIndex == 0) {
      body = StreakPage(userId: widget.userId, color: mainColor);
    } else if (_selectedIndex == 1) {
      body = FolderPage(userId: widget.userId, color: mainColor);
    } else if (_selectedIndex == 2) {
      body = StorePage(userId: widget.userId, color: mainColor);
    } else {
      body = FolderPage(userId: widget.userId, color: mainColor);
    }

    return Scaffold(
      extendBody: true,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: DrawerContent(
          color: mainColor,
        ),
      ),
      body: body,
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFolderPage()),
                );
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add_rounded,
                color: getShade(mainColor, 800),
                size: 30,
              ),
            )
          : null,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 3,
        tabBuilder: (int index, bool isActive) {
          const color = Colors.white;
          final showLabel = isActive || _selectedIndex == index;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                index == 0
                    ? Icons.fireplace_rounded
                    : index == 1
                        ? Icons.folder
                        : Icons.person,
                size: 55,
                color: color,
              ),
              if (showLabel)
                Text(
                  index == 0
                      ? 'Streak'
                      : index == 1
                          ? 'Folders'
                          : 'Store',
                  style: const TextStyle(
                    color: color,
                    fontSize: 8,
                    fontFamily: 'PressStart2P',
                  ),
                )
            ],
          );
        },
        backgroundColor: getShade(mainColor, 800),
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
