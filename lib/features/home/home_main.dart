import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/features/home/folder%20widget/add_folder_page.dart';
import 'package:learn_n/features/home/home%20pages/acrivity_page.dart';
import 'package:learn_n/features/home/home%20pages/folder_page.dart';
import 'package:learn_n/features/home/home%20pages/setting_page.dart';

class HomeMain extends ConsumerStatefulWidget {
  final String userId;

  const HomeMain({super.key, required this.userId});

  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends ConsumerState<HomeMain>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

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
    final userColor = ref.watch(userColorProvider);

    Widget body;
    if (_selectedIndex == 0) {
      body = ActivtyPage(userId: widget.userId);
    } else if (_selectedIndex == 1) {
      body = FolderPage(userId: widget.userId);
    } else if (_selectedIndex == 2) {
      body = SettingPage(userId: widget.userId);
    } else {
      body = FolderPage(userId: widget.userId);
    }

    return Scaffold(
      extendBody: true,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
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
                color: getShade(userColor, 800),
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
                    ? Icons.school_rounded
                    : index == 1
                        ? Icons.storage_rounded
                        : Icons.attractions_rounded,
                size: 55,
                color: color,
              ),
              if (showLabel)
                Text(
                  index == 0
                      ? 'Activity'
                      : index == 1
                          ? 'Library'
                          : 'Options',
                  style: const TextStyle(
                    color: color,
                    fontSize: 8,
                    fontFamily: 'PressStart2P',
                  ),
                )
            ],
          );
        },
        backgroundColor: userColor,
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
