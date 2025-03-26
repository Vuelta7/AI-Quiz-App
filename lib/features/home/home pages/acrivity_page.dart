import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/home/folder%20widget/folder_model.dart';
import 'package:lottie/lottie.dart';

class ActivtyPage extends ConsumerStatefulWidget {
  const ActivtyPage({super.key});

  @override
  _ActivtyPageState createState() => _ActivtyPageState();
}

class _ActivtyPageState extends ConsumerState<ActivtyPage> {
  String _petName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = ref.watch(userIdProvider);
    if (userId != null) {
      _fetchPetName(userId);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchPetName(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();
    setState(() {
      _petName = userSnapshot.data()?['petName'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);
    final userId = ref.watch(userIdProvider);
    return Scaffold(
      backgroundColor: getShade(userColor, 300),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Lottie.asset(
                  'assets/effectbg.json',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
                Lottie.asset(
                  'assets/streakpet3.json',
                  width: double.infinity,
                  height: 300,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                _petName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
              decoration: BoxDecoration(
                color: getShade(userColor, 600),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Weekly Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FolderModel(
                    folderId: '4612',
                    folderName: 'Programming Fundamentals',
                    description:
                        'This Folder helps you to learn the basics of programming terms.',
                    isImported: true,
                    headerColor: getShade(userColor, 900),
                    userId: userId!,
                    isActivity: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FolderModel(
                    folderId: '4612',
                    folderName: 'SQL Fundamentals',
                    description:
                        'This Folder helps you to learn the basics of Database terms.',
                    isImported: true,
                    headerColor: getShade(userColor, 900),
                    userId: userId,
                    isActivity: true,
                  ),
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

                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final currencyPoints = userData['currencypoints'] ?? 0;
                      final hints = userData['hints'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Points: $currencyPoints',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            buildRetroButton(
                              'Buy Hint (50 points)',
                              userColor,
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
                              userColor,
                              currencyPoints >= 100
                                  ? () async {
                                      String newName =
                                          await _showChangePetNameDialog(
                                              context, userColor);
                                      if (newName.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .update({
                                          'currencypoints':
                                              currencyPoints - 100,
                                          'petName': newName,
                                        });
                                      }
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            buildRetroButton(
                              'Change Username (1000 points)',
                              userColor,
                              currencyPoints >= 500
                                  ? () async {
                                      String newUsername =
                                          await _showChangeUsernameDialog(
                                              context, userColor);
                                      if (newUsername.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .update({
                                          'currencypoints':
                                              currencyPoints - 1000,
                                          'username': newUsername,
                                        });
                                      }
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 200),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _showChangePetNameDialog(
      BuildContext context, userColor) async {
    String newName = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: userColor,
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
              fillColor: getShade(userColor, 600),
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

  Future<String> _showChangeUsernameDialog(
      BuildContext context, userColor) async {
    String newUsername = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: userColor,
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
              fillColor: getShade(userColor, 600),
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
