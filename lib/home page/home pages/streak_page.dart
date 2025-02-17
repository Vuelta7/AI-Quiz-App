import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:learn_n/components/loading.dart';
import 'package:learn_n/utils/color_utils.dart';
import 'package:lottie/lottie.dart';

class StreakPage extends StatefulWidget {
  final String userId;
  final Color color;

  const StreakPage({super.key, required this.userId, required this.color});

  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  String _petName = 'Augy chan';

  @override
  void initState() {
    super.initState();
    _fetchPetName();
  }

  Future<void> _fetchPetName() async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userSnapshot = await userDoc.get();
    setState(() {
      _petName = userSnapshot.data()?['petName'] ?? 'Augy chan';
    });
  }

  Future<Map<DateTime, int>> _fetchHeatmapData() async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userSnapshot = await userDoc.get();
    final heatmapData = userSnapshot.data()?['heatmap'] ?? {};

    Map<DateTime, int> parsedData = {};

    heatmapData.forEach((key, value) {
      try {
        List<String> parts = key.split('-');
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);
        parsedData[DateTime(year, month, day)] = value;
      } catch (e) {
        print('Error parsing date: $key');
      }
    });

    return parsedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getShade(widget.color, 300),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Lottie.asset(
                  'assets/effectbg.json',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
                Lottie.asset(
                  'assets/streakpet3.json',
                  width: double.infinity,
                  height: 300,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                _petName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            FutureBuilder<Map<DateTime, int>>(
              future: _fetchHeatmapData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading heatmap data'));
                } else {
                  final heatmapData = snapshot.data;
                  return Container(
                    color: widget.color,
                    child: HeatMap(
                      datasets: heatmapData,
                      endDate: DateTime.now().add(
                        const Duration(days: 40),
                      ),
                      size: 37.0,
                      showText: false,
                      scrollable: true,
                      colorsets: const {
                        0: Color.fromARGB(0, 2, 179, 8),
                        1: Color.fromARGB(40, 2, 179, 8),
                        5: Color.fromARGB(80, 2, 179, 8),
                        10: Color.fromARGB(150, 2, 179, 8),
                        20: Color.fromARGB(250, 2, 179, 8),
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
