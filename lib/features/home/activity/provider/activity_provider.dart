import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_provider.dart';

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

final streakPointsProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value(0);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    final streakDays = snapshot.data()?['streakDays'] as List<dynamic>? ?? [];
    return streakDays.length;
  });
});
