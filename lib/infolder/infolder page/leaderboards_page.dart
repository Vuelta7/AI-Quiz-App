import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_n/utils/loading.dart';
import 'package:lottie/lottie.dart';

//TODO: fix the creator badge
class LeaderboardPage extends StatelessWidget {
  final String folderId;

  const LeaderboardPage({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .collection('leaderboard')
          .orderBy('timeSpent')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No leaderboard data available.'),
          );
        }

        final leaderboardEntries = snapshot.data!.docs;
        int userRank = -1;
        for (int i = 0; i < leaderboardEntries.length; i++) {
          if (leaderboardEntries[i].id == folderId) {
            userRank = i + 1;
            break;
          }
        }

        return Column(
          children: [
            Lottie.asset('assets/award.json'),
            const Divider(
              color: Colors.white,
              thickness: 5,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboardEntries.length > 10
                    ? 11
                    : leaderboardEntries.length,
                itemBuilder: (context, index) {
                  if (index < 10) {
                    final entry = leaderboardEntries[index];
                    final data = entry.data() as Map<String, dynamic>;
                    final username = data['username'] as String;
                    final timeSpent = data['timeSpent'] as int;

                    return ListTile(
                      leading: Icon(
                        index == 0
                            ? Icons.looks_one
                            : index == 1
                                ? Icons.looks_two
                                : index == 2
                                    ? Icons.looks_3
                                    : Icons.person,
                        color: Colors.white,
                      ),
                      title: Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (entry.id == folderId)
                            const Icon(
                              Icons.create_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'Time Spent: ${NumberFormat.decimalPattern().format(timeSpent)}s',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else if (userRank > 10) {
                    final entry = leaderboardEntries[userRank - 1];
                    final data = entry.data() as Map<String, dynamic>;
                    final username = data['username'] as String;
                    final timeSpent = data['timeSpent'] as int;

                    return ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      title: Row(
                        children: [
                          Text(username),
                          if (entry.id == folderId)
                            const Icon(
                              Icons.create_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'Time Spent: ${NumberFormat.decimalPattern().format(timeSpent)}s',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing: Text(
                        'Rank: $userRank',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
