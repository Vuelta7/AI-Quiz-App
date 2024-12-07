import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_n/notification.dart';

// Reusable Retro Button widget
Widget buildRetroButton(String text, Color color, VoidCallback? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(
          vertical: 16, horizontal: 32), // Increased padding for bigger buttons
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            12), // Increased border radius for a more stylish button
      ),
      minimumSize: const Size(200, 50), // Set a minimum size to avoid overflow
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 18, // Increased font size for better visibility
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    ),
  );
}

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  TimeOfDay? selectedTime;
  bool isDndEnabled = false;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
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
      Timer(Duration(seconds: delay), _sendNotification);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Notification set for ${time.format(context)}!",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please pick a future time!"),
        ),
      );
    }
  }

  void _sendNotification() {
    if (!isDndEnabled) {
      NotificationService.showInstantNotification(
        'Time to Study!',
        'Keep pushing forward — your future self will thank you!',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("DND is enabled. Notification not sent."),
        ),
      );
    }
  }

  Widget _buildDndSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            "🔕 Do Not Disturb (DND)",
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 20,
            ),
          ),
        ),
        // Wrap the text and switch in a column for them to appear on separate lines
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Enable DND: ",
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 18,
                ),
              ),
            ),
            Switch(
              value: isDndEnabled,
              onChanged: (value) {
                setState(() {
                  isDndEnabled = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // Notification settings section
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
            ),
          ),
        ),
        Center(
          child: buildRetroButton(
            "Select Time",
            Colors.purple,
            _pickTime,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16), // Slightly larger radius for the dialog
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Increased padding for more space
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationSettings(),
            const SizedBox(height: 30), // Increased space between sections
            _buildDndSettings(),
            const SizedBox(height: 30), // Increased space between sections
            buildRetroButton(
              "Close",
              Colors.red,
              () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const NotificationDialog();
    },
  );
}
