import 'package:flutter/material.dart';

class HomeAppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'My Decks',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'PressStart2P',
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, size: 30),
        color: Colors.black,
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, size: 30),
          color: Colors.black,
          onPressed: () {
            print('Notification button pressed');
          },
        ),
      ],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3.0),
        child: Column(
          children: [
            Container(
              color: Colors.black,
              height: 4.0,
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              height: 2.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
