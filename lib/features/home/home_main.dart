import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/provider/user_provider.dart';
import 'package:learn_n/core/widgets/learnn_icon.dart';
import 'package:learn_n/core/widgets/learnn_text.dart';
import 'package:learn_n/features/home/activity/page/activity_page.dart';
import 'package:learn_n/features/home/folder/page/add_folder_page.dart';
import 'package:learn_n/features/home/folder/page/folder_page.dart';
import 'package:learn_n/features/home/settings/setting_page.dart';
import 'package:lottie/lottie.dart';

class HomeMain extends ConsumerStatefulWidget {
  const HomeMain({super.key});

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

    loadUserId(ref);
    loadUserColor(ref);

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

    _checkStreakWarning();
    _updateStreakPoints();
  }

  Future<void> _updateStreakPoints() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    final today = DateTime.now();
    final todayDateString =
        DateTime(today.year, today.month, today.day).toIso8601String();

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    final userData = snapshot.data();

    final streakDays = (userData?['streakDays'] as List<dynamic>?) ?? [];

    bool containsToday = false;
    for (final day in streakDays) {
      final date = DateTime.parse(day);
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        containsToday = true;
        break;
      }
    }

    if (!containsToday) {
      await userDoc.update({
        'streakDays': FieldValue.arrayUnion([todayDateString]),
      });
    }
  }

  Future<void> _checkStreakWarning() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    final data = snapshot.data();

    final streakDays = (data?['streakDays'] as List<dynamic>?) ?? [];
    final warningGiven = data?['warningGiven'] as bool? ?? false;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (streakDays.isEmpty) return;

    final lastStreakDate = DateTime.parse(streakDays.last);
    print('lastStreakDate: $lastStreakDate');

    if (warningGiven) {
      if (lastStreakDate.isBefore(yesterday)) {
        await userDoc.update({'streakDays': [], 'warningGiven': false});

        Future.delayed(Duration.zero, () {
          _showWarningDialog(
              context,
              ref.read(userColorProvider),
              'Streak Lost!',
              'You didn’t log in for too long, and your streak has been reset to 0.');
        });

        return;
      }

      if (streakDays.length >= 2) {
        await userDoc.update({'warningGiven': false});
      }
    }

    if (lastStreakDate.isBefore(yesterday)) {
      if (lastStreakDate.isBefore(today.subtract(const Duration(days: 2)))) {
        await userDoc.update({'streakDays': []});

        Future.delayed(Duration.zero, () {
          _showWarningDialog(
              context,
              ref.read(userColorProvider),
              'Streak Lost!',
              'You didn’t log in for too long, and your streak has been reset to 0.');
        });
      } else {
        await userDoc.update({'warningGiven': true});

        Future.delayed(Duration.zero, () {
          _showWarningDialog(context, ref.read(userColorProvider), 'Warning',
              'You missed a day! If you miss another day, your streak points will reset to 0.');
        });
      }
    }
  }

  void _showWarningDialog(
      BuildContext context, Color color, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final textIconColor = ref.watch(textIconColorProvider);
        return AlertDialog(
          backgroundColor: color,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'PressStart2P',
              color: textIconColor,
            ),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/sadstar.json'),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textIconColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'press',
                  color: textIconColor,
                ),
              ),
            ),
          ],
        );
      },
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
    final textIconColor = ref.watch(textIconColorProvider);

    Widget body;
    if (_selectedIndex == 0) {
      body = const ActivtyPage();
    } else if (_selectedIndex == 1) {
      body = const FolderPage();
    } else if (_selectedIndex == 2) {
      body = const SettingPage();
    } else {
      body = const FolderPage();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                backgroundColor: textIconColor,
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
            final showLabel = isActive || _selectedIndex == index;

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LearnNIcon(
                  icon: index == 0
                      ? Icons.school_rounded
                      : index == 1
                          ? Icons.folder_rounded
                          : Icons.attractions_rounded,
                  color: textIconColor,
                  size: 55,
                  shadowColor: getShade(userColor, 500),
                  offset: const Offset(2, 2),
                ),
                if (showLabel)
                  LearnNText(
                    fontSize: 8,
                    text: index == 0
                        ? 'Activity'
                        : index == 1
                            ? 'Library'
                            : 'Options',
                    font: 'PressStart2P',
                    color: textIconColor,
                    backgroundColor: getShade(userColor, 500),
                    offset: const Offset(2, 2),
                  ),
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
      ),
    );
  }
}
