import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/home%20page/drawer%20page/dnd_page.dart';
import 'package:learn_n/home%20page/drawer%20page/themes_page.dart';
import 'package:learn_n/start%20page/introduction/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerContent extends StatefulWidget {
  const DrawerContent({super.key, required this.selectedColor});
  final Color? selectedColor;

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  void _showDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('diko pa tapos to hehe'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: widget.selectedColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/logo_icon.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const Text(
                'Learn-N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: widget.selectedColor,
                ),
                title: const Text('About Us'),
                onTap: () {
                  _showDialog(context, 'About Us');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.privacy_tip,
                  color: widget.selectedColor,
                ),
                title: const Text('Privacy Policy'),
                onTap: () {
                  _showDialog(context, 'Privacy Policy');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.feedback,
                  color: widget.selectedColor,
                ),
                title: const Text('Feedback and Question'),
                onTap: () {
                  _showDialog(context, 'Feedback and Question');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.do_not_disturb_alt_rounded,
                  color: widget.selectedColor,
                ),
                title: const Text('Do not Disturb Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoNotDisturbPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.color_lens,
                  color: widget.selectedColor,
                ),
                title: const Text('Themes'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.red,
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('userID');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LiquidSwipeIntro()),
            );
          },
        ),
      ],
    );
  }
}
