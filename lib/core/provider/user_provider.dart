import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userIdProvider = StateProvider<String?>((ref) => null);

class UserIdRepository {
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}

Future<void> loadUserId(WidgetRef ref) async {
  final userId = await UserIdRepository().getUserId();
  ref.read(userIdProvider.notifier).state = userId;
}

final userProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) return false;

  final snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!snapshot.exists) return false;

  final data = snapshot.data();
  return data?['isVIP'] ?? false;
});
