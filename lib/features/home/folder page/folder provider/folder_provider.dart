import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final folderStreamProvider = StreamProvider((ref) {
  ref.keepAlive();
  return FirebaseFirestore.instance.collection('folders').snapshots();
});
