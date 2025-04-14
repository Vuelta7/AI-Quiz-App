import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/features/home/activity/provider/activity_provider.dart';

final streakPetProvider = FutureProvider<String>((ref) async {
  final streakPoints = await ref.watch(streakPointsProvider.future);
  if (streakPoints >= 30) {
    return 'assets/streakpet1.json';
  } else if (streakPoints >= 10) {
    return 'assets/streakpet2.json';
  } else {
    return 'assets/streakpet3.json';
  }
});
