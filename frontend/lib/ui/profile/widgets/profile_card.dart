import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  const ProfileCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(name)));
  }
}
