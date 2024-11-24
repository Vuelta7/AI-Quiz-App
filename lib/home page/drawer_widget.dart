import 'package:flutter/material.dart';

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
