import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final String value;

  const DashboardTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.indigo),
        ),
      ),
    );
  }
}
