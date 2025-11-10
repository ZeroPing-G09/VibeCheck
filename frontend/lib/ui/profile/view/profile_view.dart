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
  String? _selectedGenre;
  late final TextEditingController _usernameController;
  late final TextEditingController _profilePicController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _profilePicController = TextEditingController();

    // Load user and then populate controllers when the user is available.
    context.read<ProfileViewModel>().loadUser(1).then((_) {
      final user = context.read<ProfileViewModel>().user;
      if (user != null) {
        _usernameController.text = user.username;
        _profilePicController.text = user.profilePicture;
        // Trigger a rebuild to reflect controller values in the UI.
        if (mounted) setState(() {});
      }
    });

    context.read<ProfileViewModel>().loadAvailableGenres();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _profilePicController.dispose();
    super.dispose();
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

  // Use state controllers. They were populated after loadUser completes.
  final usernameController = _usernameController;
  final profilePicController = _profilePicController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
    child: CircleAvatar(
    radius: 50,
    backgroundImage: (profilePicController.text.isNotEmpty &&
      (profilePicController.text.startsWith('http') ||
          profilePicController.text.startsWith('https')))
        ? NetworkImage(profilePicController.text)
        : null,
    child: (profilePicController.text.isEmpty ||
      !(profilePicController.text.startsWith('http') ||
          profilePicController.text.startsWith('https')))
        ? const Icon(Icons.person, size: 48)
        : null,
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
              decoration:
                  const InputDecoration(labelText: 'Profile Picture URL'),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Favorite Genres',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Genre Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.genres
                  .map(
                    (g) => Chip(
                      label: Text(g),
                      onDeleted: () {
                        setState(() => user.genres.remove(g));
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),

            if (user.genres.length < 3)
              DropdownButton<String>(
                hint: const Text('Select Genre'),
                value: _selectedGenre,
                items: viewModel.availableGenres
                    .where((g) => !user.genres.contains(g))
                    .map(
                      (g) => DropdownMenuItem(value: g, child: Text(g)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedGenre = value);
                },
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.warning_amber_rounded,
                    color: Colors.amber),
                label: const Text("You can only choose 3 genres"),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Limit Reached'),
                      content:
                          const Text('You can only select up to 3 genres.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Genre'),
              onPressed: _selectedGenre != null && user.genres.length < 3
                  ? () {
                      setState(() {
                        user.genres.add(_selectedGenre!);
                        _selectedGenre = null;
                      });
                    }
                  : null,
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text(
                'Submit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final updated = user.copyWith(
                  username: usernameController.text,
                  profilePicture: profilePicController.text,
                  genres: user.genres,
                );

                try {
                  // Attempt to update; surface errors to the user so we can
                  // see why the call might be failing (network, CORS, etc.).
                  await viewModel.updateUser(updated);

                  if (context.mounted) {
                    await showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Profile Updated'),
                        content: const Text(
                          'Your profile has been successfully updated.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated successfully!')),
                    );
                  }
                } catch (e, st) {
                  // Log to console for debugging and show a dialog/snackbar to
                  // make the failure visible in the UI.
                  debugPrint('Error updating profile: $e');
                  debugPrint('$st');
                  if (context.mounted) {
                    await showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Update Failed'),
                        content: Text('Failed to update profile:\n$e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
