import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_n/home%20page/dashboard%20page/streak.dart';
import 'package:learn_n/home%20page/home%20page%20util/home_page_appbar.dart';

class Dashboard extends StatefulWidget {
  final String userId;

  const Dashboard({super.key, required this.userId});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedOption == 0) {
      body = const StreakPage();
    } else if (_selectedOption == 1) {
      body = _buildShop();
    } else {
      body = _buildLeaderboards();
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildOptionButton('Shop', 1)),
              Expanded(child: _buildOptionButton('Analytics', 0)),
              Expanded(child: _buildOptionButton('Rank', 2)),
            ],
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: _selectedOption == index ? Colors.black : Colors.white,
          border: Border(
            bottom: BorderSide(
              color:
                  _selectedOption == index ? Colors.black : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: _selectedOption == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboards() {
    return StreamBuilder<QuerySnapshot>(
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
          if (users[i].id == widget.userId) {
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
    );
  }

  Widget _buildShop() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('User data not found.'),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final currencyPoints = userData['currencypoints'] ?? 0;
        final hints = userData['hints'] ?? 0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Currency Points: $currencyPoints'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: currencyPoints >= 50
                  ? () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'currencypoints': currencyPoints - 50,
                        'hints': hints + 1,
                      });
                    }
                  : null,
              child: const Text('Buy Hint (50 points)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: currencyPoints >= 500
                  ? () {
                      // Implement color change functionality
                    }
                  : null,
              child: const Text('Change App Color (500 points)'),
            ),
          ],
        );
      },
    );
  }
}
