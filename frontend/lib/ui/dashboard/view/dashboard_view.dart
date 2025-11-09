import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeCheck Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthRepository().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user logged in')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.userMetadata?['avatar_url'] != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          NetworkImage(user.userMetadata!['avatar_url'].toString()),
                    ),
                  const SizedBox(height: 16),
                  Text('Welcome, ${user.userMetadata?['name'] ?? 'User'}'),
                  Text(user.email ?? ''),
                ],
              ),
      ),
    );
  }
}
