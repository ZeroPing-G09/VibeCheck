import 'package:flutter/material.dart';
import '../widgets/dashboard_title.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockStats = [
      {'title': 'Songs listened', 'value': '345'},
      {'title': 'Active hours', 'value': '12'},
      {'title': 'Playlists', 'value': '5'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Center(
            child: const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12), // un fel de padding
          for (var item in mockStats)
            DashboardTile(title: item['title']!, value: item['value']!),
        ],
      ),
    );
  }
}
