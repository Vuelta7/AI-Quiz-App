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
