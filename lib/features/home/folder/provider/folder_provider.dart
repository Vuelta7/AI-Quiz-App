import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final folderStreamProvider = StreamProvider((ref) {
  ref.keepAlive();
  return FirebaseFirestore.instance.collection('folders').snapshots();
});

final folderControllerProvider = StateNotifierProvider<FolderController, bool>(
  (ref) => FolderController(),
);

class FolderController extends StateNotifier<bool> {
  FolderController() : super(false); // false = not loading

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _generateUnique4DigitCode() async {
    final random = Random();
    String code = '';
    bool exists = true;

    while (exists) {
      code = (1000 + random.nextInt(9000)).toString();
      final doc = await _firestore.collection("folders").doc(code).get();
      if (!doc.exists) {
        exists = false;
      }
    }
    return code;
  }

  Future<void> uploadFolderToDb({
    required String folderName,
    required String description,
    required String color,
  }) async {
    state = true;
    try {
      final id = await _generateUnique4DigitCode();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      await _firestore.collection("folders").doc(id).set({
        "folderName": folderName,
        "description": description,
        "creator": userId,
        "color": color,
        "accessUsers": [],
      });
    } finally {
      state = false;
    }
  }

  Future<void> importFolder(String folderId) async {
    state = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      await _firestore.collection("folders").doc(folderId).update({
        "accessUsers": FieldValue.arrayUnion([userId]),
      });
    } finally {
      state = false;
    }
  }

  Future<void> editFolder({
    required String folderId,
    required String folderName,
    required String description,
    required String color,
  }) async {
    state = true;
    try {
      await _firestore.collection("folders").doc(folderId).update({
        "folderName": folderName,
        "description": description,
        "color": color,
      });
    } finally {
      state = false;
    }
  }

  // ✅ Delete folder with subcollections
  Future<void> deleteFolderWithSubcollections(String folderId) async {
    state = true;
    try {
      final folderRef = _firestore.collection('folders').doc(folderId);

      // Delete 'questions'
      final questions = await folderRef.collection('questions').get();
      for (final doc in questions.docs) {
        await doc.reference.delete();
      }

      // Delete 'leaderboard'
      final leaderboard = await folderRef.collection('leaderboard').get();
      for (final doc in leaderboard.docs) {
        await doc.reference.delete();
      }

      // Delete the folder itself
      await folderRef.delete();
    } finally {
      state = false;
    }
  }
}
