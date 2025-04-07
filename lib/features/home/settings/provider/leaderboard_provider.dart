import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/provider/user_provider.dart';

final leaderboardProvider = FutureProvider.autoDispose((ref) async {
  final userId = ref.watch(userIdProvider);

  // Fetch all users for leaderboard
  final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

  List<UserRanking> streakRankings = [];
  List<UserRanking> donationRankings = [];

  // Process the data for both leaderboards
  for (var doc in usersSnapshot.docs) {
    final data = doc.data();
    final userId = doc.id;
    final username = data['username'] ?? 'Unknown';

    // Calculate streak (using length of streakDays array)
    final streakDays = data['streakDays'] ?? [];
    final streakValue = streakDays is List ? streakDays.length : 0;

    // Get donation amount
    final donationValue = data['donation'] ?? 0;

    // Add to respective lists
    streakRankings.add(UserRanking(
      id: userId,
      name: username,
      value: streakValue,
      rank: 0, // We'll calculate ranks later
    ));

    donationRankings.add(UserRanking(
      id: userId,
      name: username,
      value: donationValue,
      rank: 0, // We'll calculate ranks later
    ));
  }

  // Sort and assign ranks for streak leaderboard
  streakRankings.sort((a, b) => b.value.compareTo(a.value));
  for (int i = 0; i < streakRankings.length; i++) {
    // If this user has the same value as the previous user, give them the same rank
    if (i > 0 && streakRankings[i].value == streakRankings[i - 1].value) {
      streakRankings[i] = UserRanking(
        id: streakRankings[i].id,
        name: streakRankings[i].name,
        value: streakRankings[i].value,
        rank: streakRankings[i - 1].rank,
      );
    } else {
      streakRankings[i] = UserRanking(
        id: streakRankings[i].id,
        name: streakRankings[i].name,
        value: streakRankings[i].value,
        rank: i + 1, // Ranks start at 1
      );
    }
  }

  // Sort and assign ranks for donation leaderboard
  donationRankings.sort((a, b) => b.value.compareTo(a.value));
  for (int i = 0; i < donationRankings.length; i++) {
    // If this user has the same value as the previous user, give them the same rank
    if (i > 0 && donationRankings[i].value == donationRankings[i - 1].value) {
      donationRankings[i] = UserRanking(
        id: donationRankings[i].id,
        name: donationRankings[i].name,
        value: donationRankings[i].value,
        rank: donationRankings[i - 1].rank,
      );
    } else {
      donationRankings[i] = UserRanking(
        id: donationRankings[i].id,
        name: donationRankings[i].name,
        value: donationRankings[i].value,
        rank: i + 1, // Ranks start at 1
      );
    }
  }

  return {
    'streakData': streakRankings,
    'donationData': donationRankings,
    'currentUserId': userId,
  };
});

class LeaderboardWidget extends StatelessWidget {
  final String title;
  final List<UserRanking> rankings;
  final String currentUserId;
  final String valueLabel;
  final bool valuePrefix;

  const LeaderboardWidget({
    super.key,
    required this.title,
    required this.rankings,
    required this.currentUserId,
    required this.valueLabel,
    this.valuePrefix = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserRanking = rankings.firstWhere(
      (user) => user.id == currentUserId,
      orElse: () =>
          UserRanking(id: currentUserId, name: 'You', value: 0, rank: 0),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: title == 'Streak' ? Colors.blue : Colors.orange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Top 3 users
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Display top 3 users
                ...rankings.take(3).map(
                      // This will take only the first 3 items
                      (user) => LeaderboardItem(
                        user: user,
                        isCurrentUser: user.id == currentUserId,
                        valueLabel: valueLabel,
                        valuePrefix: valuePrefix,
                      ),
                    ),

                const Divider(height: 24),

                LeaderboardItem(
                  user: currentUserRanking,
                  isCurrentUser: true,
                  valueLabel: valueLabel,
                  valuePrefix: valuePrefix,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardItem extends ConsumerWidget {
  final UserRanking user;
  final bool isCurrentUser;
  final String valueLabel;
  final bool valuePrefix;

  const LeaderboardItem({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.valueLabel,
    this.valuePrefix = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = ref.watch(textIconColorProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? Colors.amber.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(user.rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${user.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User name
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser ? Colors.amber : textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Value
          Text(
            valuePrefix
                ? '$valueLabel${user.value}'
                : '${user.value} $valueLabel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.grey.shade600;
    }
  }
}

class UserRanking {
  final String id;
  final String name;
  final int value;
  final int rank;

  UserRanking({
    required this.id,
    required this.name,
    required this.value,
    required this.rank,
  });
}
