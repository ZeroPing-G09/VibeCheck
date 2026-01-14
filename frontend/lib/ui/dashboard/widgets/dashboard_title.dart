import 'package:flutter/material.dart';

/// A reusable tile widget for displaying a title and a corresponding value 
/// in the dashboard.
class DashboardTile extends StatelessWidget {

  /// Creates a [DashboardTile] with the given [title] and [value]
  const DashboardTile({required this.title, required this.value, super.key});
  /// The title to display on the left side of the tile
  final String title;

  /// The value to display on the right side of the tile
  final String value;

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
