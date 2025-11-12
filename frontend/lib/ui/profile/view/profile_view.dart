import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_view_model.dart';
import '../widgets/profile_sidebar.dart';
import '../widgets/profile_picture_section.dart';
import '../widgets/genres_section.dart';
import '../widgets/save_button.dart';
import '../widgets/custom_text_field.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final TextEditingController _usernameController;
  late final TextEditingController _profilePicController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _profilePicController = TextEditingController();
    final vm = context.read<ProfileViewModel>();
    vm.loadUser(1).then((_) {
      final user = vm.user;
      if (user != null) {
        _usernameController.text = user.username;
        _profilePicController.text = user.profilePicture;
        if (mounted) setState(() {});
      }
    });
    vm.loadAvailableGenres();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _profilePicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final user = vm.user;

    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (user == null) return const Center(child: Text('No user data'));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          const ProfileSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("My Profile",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ProfilePictureSection(
                    controller: _profilePicController,
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: "Username",
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 32),
                  GenresSection(user: user),
                  const SizedBox(height: 40),
                  SaveButton(
                    onSave: () async {
                      final updated = user.copyWith(
                        username: _usernameController.text,
                        profilePicture: _profilePicController.text,
                        genres: user.genres,
                      );
                      await vm.updateUser(updated);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Profile updated successfully!"),
                            backgroundColor: Colors.green));
                      }
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
