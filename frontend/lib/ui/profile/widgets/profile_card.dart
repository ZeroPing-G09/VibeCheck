import 'package:flutter/material.dart';

/// A simple profile card widget that displays a user's name.
class ProfileCard extends StatelessWidget {
  /// Creates a [ProfileCard] widget.
  const ProfileCard({required this.name, super.key});
  /// The name of the user to display.
  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(name)));
  }
}
