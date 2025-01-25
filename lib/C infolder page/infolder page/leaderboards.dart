import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No leaderboard data available.'),
          );
        }

        final leaderboardEntries = snapshot.data!.docs;

        return ListView.builder(
          itemCount: leaderboardEntries.length,
          itemBuilder: (context, index) {
            final entry = leaderboardEntries[index];
            final data = entry.data() as Map<String, dynamic>;
            final username = data['username'] as String;
            final timeSpent = data['timeSpent'] as int;

            return ListTile(
              title: Text(username),
              subtitle: Text('Time Spent: ${timeSpent}s'),
            );
          },
        );
      },
    );
  }
}
