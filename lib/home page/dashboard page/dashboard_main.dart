import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:learn_n/components/loading.dart';
import 'package:learn_n/home%20page/dashboard%20page/streak.dart';
import 'package:learn_n/start%20page/start%20page%20utils/start_page_button.dart';
import 'package:lottie/lottie.dart';

class Dashboard extends StatefulWidget {
  final String userId;
  final Color color;

  const Dashboard({super.key, required this.userId, required this.color});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedOption == 0) {
      body = StreakPage(
        userId: widget.userId,
        color: widget.color,
      );
    } else if (_selectedOption == 1) {
      body = _buildShop();
    } else {
      body = _buildLeaderboards();
    }

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildOptionButton('Store', 1)),
              Expanded(child: _buildOptionButton('Analytics', 0)),
              Expanded(child: _buildOptionButton('Ranking', 2)),
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
          color: _selectedOption == index ? widget.color : Colors.white,
          border: Border(
            bottom: BorderSide(
              color:
                  _selectedOption == index ? widget.color : Colors.transparent,
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
    return Container(
      color: getShade(widget.color, 300),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('rankpoints', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
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
                    color: Colors.white,
                  ),
                  title: Text(
                    user['username'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rank Points: ${NumberFormat.decimalPattern().format(user['rankpoints'])}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (userRank > 10) {
                final user = users[userRank - 1];
                return ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  title: Text(
                    user['username'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rank Points: ${NumberFormat.decimalPattern().format(user['rankpoints'])}',
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
          );
        },
      ),
    );
  }

  Widget _buildShop() {
    return Container(
      color: getShade(widget.color, 300),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Lottie.asset('assets/hints.json'),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('User data not found.'),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final currencyPoints = userData['currencypoints'] ?? 0;
                final hints = userData['hints'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Currency Points: $currencyPoints',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      buildRetroButton(
                        'Buy Hint (50 points)',
                        widget.color,
                        currencyPoints >= 50
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
                      ),
                      const SizedBox(height: 20),
                      buildRetroButton(
                        'Change Streak Pet Name (100 points)',
                        widget.color,
                        currencyPoints >= 100
                            ? () async {
                                String newName =
                                    await _showChangePetNameDialog();
                                if (newName.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userId)
                                      .update({
                                    'currencypoints': currencyPoints - 100,
                                    'petName': newName,
                                  });
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      buildRetroButton(
                        'Change Username (1000 points)',
                        widget.color,
                        currencyPoints >= 500
                            ? () async {
                                String newUsername =
                                    await _showChangeUsernameDialog();
                                if (newUsername.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userId)
                                      .update({
                                    'currencypoints': currencyPoints - 1000,
                                    'username': newUsername,
                                  });
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _showChangePetNameDialog() async {
    String newName = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: widget.color,
          title: const Text(
            'Change Pet Name',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            controller: controller,
            cursorColor: Colors.white,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Pet Name',
              labelText: 'Pet Name',
              labelStyle: const TextStyle(
                fontFamily: 'PressStart2P',
                color: Colors.white,
              ),
              filled: true,
              fillColor: getShade(widget.color, 600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                newName = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return newName;
  }

  Future<String> _showChangeUsernameDialog() async {
    String newUsername = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: widget.color,
          title: const Text(
            'Change Username',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            controller: controller,
            cursorColor: Colors.white,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Username',
              labelText: 'Username',
              labelStyle: const TextStyle(
                fontFamily: 'PressStart2P',
                color: Colors.white,
              ),
              filled: true,
              fillColor: getShade(widget.color, 600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                newUsername = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return newUsername;
  }
}
