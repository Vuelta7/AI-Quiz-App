import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_provider.dart';

final petNameProvider = StreamProvider<String>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value('');
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.data()?['petName'] ?? '';
  });
});
