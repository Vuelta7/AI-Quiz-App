import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_n/notification.dart';

Widget buildRetroButton(String text, Color color, VoidCallback? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: const Size(200, 50),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 12,
        color: Colors.white,
      ),
    ),
  );
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  TimeOfDay? selectedTime;
  bool isDndEnabled = false;
  late Timer _timer;
  String? timeText;
  bool isNotificationSet = false;

  List<int> timeIntervals = [5, 10, 15, 20, 25, 30];
  int? selectedInterval;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeText = "Time selected: ${picked.format(context)}";
        isNotificationSet = true;
      });
      _scheduleNotification(picked);
    }
  }

  void _scheduleNotification(TimeOfDay time) {
    final now = DateTime.now();
    final notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final delay = notificationTime.difference(now).inSeconds;

    if (delay > 0) {
      _timer = Timer(Duration(seconds: delay), _sendNotification);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick a future time!")),
      );
    }
  }

  void _sendNotification() {
    if (!isDndEnabled) {
      NotificationService.showInstantNotification(
        'Time to Study!',
        'Keep pushing forward — your future self will thank you!',
      );
    }
    setState(() {
      isNotificationSet = false;
      timeText = null;
      selectedTime = null;
    });
  }

  void _cancelNotification() {
    if (_timer.isActive) {
      _timer.cancel();
      setState(() {
        isNotificationSet = false;
        timeText = null;
        selectedTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification cancelled.")),
      );
    }
  }

  Widget _buildDndSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🔕 Do Not Disturb",
          style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 16, color: Colors.black),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Switch(
                value: isDndEnabled,
                onChanged: (value) {
                  setState(() {
                    isDndEnabled = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            "⏰ Time Interval",
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<int>(
            value: selectedInterval,
            hint: const Text(
              "Select Interval",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            icon: const Icon(
              Icons.access_time,
              color: Colors.black,
            ),
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 11,
              color: Colors.black,
            ),
            // Preventing theme inheritance
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            items: timeIntervals.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value minutes'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                selectedInterval = newValue;
              });
              if (newValue != null) {
                _scheduleIntervalNotification(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  void _scheduleIntervalNotification(int interval) {
    final now = DateTime.now();
    final notificationTime = now.add(Duration(minutes: interval));

    final delay = notificationTime.difference(now).inSeconds;

    if (delay > 0) {
      _timer = Timer(Duration(seconds: delay), _sendNotification);
      setState(() {
        timeText = "Notification set for ${interval} minutes from now.";
        isNotificationSet = true;
      });
    }
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            "📅 Time Selection",
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
        Center(
          child: buildRetroButton(
            "Select Time",
            Colors.black,
            _pickTime,
          ),
        ),
        if (timeText != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              timeText!,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        if (isNotificationSet)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: buildRetroButton(
              "Cancel Notification",
              Colors.red,
              _cancelNotification,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 4,
              ),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Notification',
              style: TextStyle(fontFamily: 'PressStart2P', color: Colors.black),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DND Settings Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 4, // Thicker border
                  ),
                  borderRadius: BorderRadius.circular(12), // Border radius
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      offset: Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: _buildDndSettings(),
              ),
              const SizedBox(height: 30),

              // Time Interval Selector Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 4, // Thicker border
                  ),
                  borderRadius: BorderRadius.circular(12), // Border radius
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      offset: Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: _buildTimeIntervalSelector(),
              ),
              const SizedBox(height: 30),
              // Notification Settings Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 4, // Thicker border
                  ),
                  borderRadius: BorderRadius.circular(12), // Border radius
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 5,
                      offset: Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: _buildNotificationSettings(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showNotificationPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const NotificationPage()),
  );
}
