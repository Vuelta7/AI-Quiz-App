import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isDndEnabled = false;
  int? timerDuration; // Duration in seconds
  bool isTimerRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DND Section
            const Text(
              "Do Not Disturb (DND)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: const Text("Enable DND while on the app"),
              value: isDndEnabled,
              onChanged: (bool value) {
                setState(() {
                  isDndEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Timer Section
            const Text(
              "Set Timer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (!isTimerRunning) ...[
              ElevatedButton(
                onPressed: _showTimePicker,
                child: const Text("Choose Time"),
              ),
            ] else ...[
              // Timer Countdown UI
              Center(
                child: Column(
                  children: [
                    Text(
                      _formatDuration(timerDuration ?? 0),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTimerRunning = false;
                          timerDuration = null;
                        });
                      },
                      child: const Text("Cancel Timer"),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int selectedMinutes = 0;

        return SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Select Timer Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  onSelectedItemChanged: (int index) {
                    selectedMinutes = index;
                  },
                  children: List<Widget>.generate(60, (int index) {
                    return Center(child: Text('$index min'));
                  }),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedMinutes > 0) {
                    setState(() {
                      timerDuration = selectedMinutes * 60;
                      isTimerRunning = true;
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text("Set Timer"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Format duration in mm:ss
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
