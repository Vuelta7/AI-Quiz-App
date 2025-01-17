import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserLeaderboards extends StatelessWidget {
  final String userId;

  const UserLeaderboards({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboards',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('rankpoints', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found.'),
            );
          }

          final users = snapshot.data!.docs;
          int userRank = -1;
          for (int i = 0; i < users.length; i++) {
            if (users[i].id == userId) {
              userRank = i + 1;
              break;
            }
          }

          return ListView.builder(
            itemCount: users.length > 10 ? 11 : users.length,
            itemBuilder: (context, index) {
              if (index < 10) {
                final user = users[index];
                return ListTile(
                  leading: Icon(
                    index == 0
                        ? Icons.looks_one
                        : index == 1
                            ? Icons.looks_two
                            : index == 2
                                ? Icons.looks_3
                                : Icons.person,
                    color: Colors.black,
                  ),
                  title: Text(user['username']),
                  subtitle: Text(
                    'Rank Points: ${NumberFormat.decimalPattern().format(user['rankpoints'])}',
                  ),
                );
              } else if (userRank > 10) {
                final user = users[userRank - 1];
                return ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  title: Text(user['username']),
                  subtitle: Text(
                    'Rank Points: ${NumberFormat.decimalPattern().format(user['rankpoints'])}',
                  ),
                  trailing: Text('Rank: $userRank'),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}
