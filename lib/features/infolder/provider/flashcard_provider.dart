import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final flashcardProvider = Provider.autoDispose((ref) {
  final firestore = FirebaseFirestore.instance;
  return FlashcardService(firestore);
});

class FlashcardService {
  final FirebaseFirestore firestore;
  FlashcardService(this.firestore);

  Future<void> upload(String folderId, String question, String answer) async {
    final id = const Uuid().v4();
    await firestore
        .collection("folders")
        .doc(folderId)
        .collection("questions")
        .doc(id)
        .set({
      "question": question,
      "answer": answer,
    });
  }

  Future<void> update(
      String folderId, String id, String question, String answer) async {
    await firestore
        .collection("folders")
        .doc(folderId)
        .collection("questions")
        .doc(id)
        .update({
      "question": question,
      "answer": answer,
    });
  }

  Future<void> delete(String folderId, String id) async {
    await firestore
        .collection("folders")
        .doc(folderId)
        .collection("questions")
        .doc(id)
        .delete();
  }

  Stream<QuerySnapshot> getFlashcards(String folderId) {
    return firestore
        .collection("folders")
        .doc(folderId)
        .collection("questions")
        .snapshots();
  }
}
