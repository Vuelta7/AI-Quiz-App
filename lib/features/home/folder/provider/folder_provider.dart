// current folder_provider.dart
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

  Future<String> _generateUnique4DigitCode() async {
    final random = Random();
    String code = '';
    bool exists = true;

    while (exists) {
      code = (1000 + random.nextInt(9000)).toString();
      final doc = await FirebaseFirestore.instance
          .collection("folders")
          .doc(code)
          .get();
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
      if (userId != null) {
        await FirebaseFirestore.instance.collection("folders").doc(id).set({
          "folderName": folderName,
          "description": description,
          "creator": userId,
          "color": color,
          "accessUsers": [],
        });
      }
    } finally {
      state = false;
    }
  }

  Future<void> importFolder(String folderId) async {
    state = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection("folders")
            .doc(folderId)
            .update({
          "accessUsers": FieldValue.arrayUnion([userId]),
        });
      }
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
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(folderId)
          .update({
        "folderName": folderName,
        "description": description,
        "color": color,
      });
    } finally {
      state = false;
    }
  }

  Future<void> removeFolderFromHome({
    required String folderId,
  }) async {
    state = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection("folders")
            .doc(folderId)
            .update({
          "accessUsers": FieldValue.arrayRemove([userId]),
        });
      }
    } finally {
      state = false;
    }
  }
}
