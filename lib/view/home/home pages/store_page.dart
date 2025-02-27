import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/color_utils.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/view/home/drawer%20widget/drawer_contents.dart';
import 'package:lottie/lottie.dart';

class StorePage extends StatelessWidget {
  final String userId;
  final Color color;
  const StorePage({super.key, required this.userId, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
      ),
      drawer: DrawerContent(color: color),
      backgroundColor: getShade(color, 300),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Lottie.asset('assets/hints.json'),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('User data not found.'),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final currencyPoints = userData['currencypoints'] ?? 0;
                final hints = userData['hints'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Currency Points: $currencyPoints',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      buildRetroButton(
                        'Buy Hint (50 points)',
                        color,
                        currencyPoints >= 50
                            ? () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .update({
                                  'currencypoints': currencyPoints - 50,
                                  'hints': hints + 1,
                                });
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      buildRetroButton(
                        'Change Streak Pet Name (100 points)',
                        color,
                        currencyPoints >= 100
                            ? () async {
                                String newName =
                                    await _showChangePetNameDialog(context);
                                if (newName.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({
                                    'currencypoints': currencyPoints - 100,
                                    'petName': newName,
                                  });
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      buildRetroButton(
                        'Change Username (1000 points)',
                        color,
                        currencyPoints >= 500
                            ? () async {
                                String newUsername =
                                    await _showChangeUsernameDialog(context);
                                if (newUsername.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({
                                    'currencypoints': currencyPoints - 1000,
                                    'username': newUsername,
                                  });
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _showChangePetNameDialog(BuildContext context) async {
    String newName = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: color,
          title: const Text(
            'Change Pet Name',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            controller: controller,
            cursorColor: Colors.white,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Pet Name',
              labelText: 'Pet Name',
              labelStyle: const TextStyle(
                fontFamily: 'PressStart2P',
                color: Colors.white,
              ),
              filled: true,
              fillColor: getShade(color, 600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                newName = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return newName;
  }

  Future<String> _showChangeUsernameDialog(BuildContext context) async {
    String newUsername = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: color,
          title: const Text(
            'Change Username',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            controller: controller,
            cursorColor: Colors.white,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Username',
              labelText: 'Username',
              labelStyle: const TextStyle(
                fontFamily: 'PressStart2P',
                color: Colors.white,
              ),
              filled: true,
              fillColor: getShade(color, 600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                newUsername = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return newUsername;
  }
}
