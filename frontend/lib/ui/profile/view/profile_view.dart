import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ProfileViewModel>().loadUser(1); 
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final user = viewModel.user;

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data')),
      );
    }

    final usernameController = TextEditingController(text: user.username);
    final profilePicController = TextEditingController(text: user.profilePicture);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updated = user.copyWith(
                username: usernameController.text,
                profilePicture: profilePicController.text,
              );
              await viewModel.updateUser(updated);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profilePicController.text),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: profilePicController,
              decoration: const InputDecoration(labelText: 'Profile Picture URL'),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Favorite Genres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.genres
                  .map((g) => Chip(
                        label: Text(g),
                        onDeleted: () {
                          setState(() => user.genres.remove(g));
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Genre'),
              onPressed: () {
                setState(() => user.genres.add('New Genre'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
