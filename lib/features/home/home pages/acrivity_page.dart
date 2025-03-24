import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/home/folder%20widget/folder_model.dart';
import 'package:lottie/lottie.dart';

class ActivtyPage extends StatefulWidget {
  final String userId;
  final Color color;

  const ActivtyPage({super.key, required this.userId, required this.color});

  @override
  _ActivtyPageState createState() => _ActivtyPageState();
}

class _ActivtyPageState extends State<ActivtyPage> {
  String _petName = '';

  @override
  void initState() {
    super.initState();
    _fetchPetName();
  }

  Future<void> _fetchPetName() async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userSnapshot = await userDoc.get();
    setState(() {
      _petName = userSnapshot.data()?['petName'] ?? 'Augy chan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getShade(widget.color, 300),
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
                color: getShade(widget.color, 600),
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
                    headerColor: getShade(widget.color, 900),
                    userId: widget.userId,
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
                    headerColor: getShade(widget.color, 900),
                    userId: widget.userId,
                    isActivity: true,
                  ),
                  Lottie.asset('assets/hints.json'),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
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
                              widget.color,
                              currencyPoints >= 50
                                  ? () async {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userId)
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
                              widget.color,
                              currencyPoints >= 100
                                  ? () async {
                                      String newName =
                                          await _showChangePetNameDialog(
                                              context);
                                      if (newName.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.userId)
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
                              widget.color,
                              currencyPoints >= 500
                                  ? () async {
                                      String newUsername =
                                          await _showChangeUsernameDialog(
                                              context);
                                      if (newUsername.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.userId)
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

  Future<String> _showChangePetNameDialog(BuildContext context) async {
    String newName = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: widget.color,
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
              fillColor: getShade(widget.color, 600),
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
          backgroundColor: widget.color,
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
              fillColor: getShade(widget.color, 600),
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
