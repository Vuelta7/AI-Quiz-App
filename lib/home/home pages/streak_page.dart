import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/home/folder%20widget/folder_model.dart';
import 'package:learn_n/utils/color_utils.dart';
import 'package:lottie/lottie.dart';

class StreakPage extends StatefulWidget {
  final String userId;
  final Color color;

  const StreakPage({super.key, required this.userId, required this.color});

  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  String _petName = 'Augy chan';

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
                color: getShade(widget.color, 500),
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
                      'Weekly Folder',
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
                    headerColor: widget.color,
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
