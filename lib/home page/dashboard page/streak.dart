import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class StreakPage extends StatelessWidget {
  final String userId;
  const StreakPage({super.key, required this.userId});

  Future<Map<DateTime, int>> _fetchHeatmapData() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
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
    return FutureBuilder<Map<DateTime, int>>(
      future: _fetchHeatmapData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading heatmap data'));
        } else {
          final heatmapData = snapshot.data;
          return Container(
            color: Colors.grey[800],
            child: HeatMap(
              datasets: heatmapData,
              endDate: DateTime.now().add(
                const Duration(days: 40),
              ),
              startDate: DateTime.now(),
              size: 30.0,
              colorMode: ColorMode.color,
              showText: false,
              scrollable: true,
              colorsets: const {
                1: Color.fromARGB(40, 2, 179, 8),
                5: Color.fromARGB(80, 2, 179, 8),
                10: Color.fromARGB(150, 2, 179, 8),
                20: Color.fromARGB(250, 2, 179, 8),
              },
            ),
          );
        }
      },
    );
  }
}
