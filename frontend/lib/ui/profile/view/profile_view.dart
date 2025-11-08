import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Center(
            child: const Text(
              'Profile',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(name: 'John Doe'),
        ],
      ),
    );
  }
}
