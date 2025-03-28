import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_provider.dart';

final petNameProvider = FutureProvider<String>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return '';

  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  return userDoc.data()?['petName'] ?? '';
});
