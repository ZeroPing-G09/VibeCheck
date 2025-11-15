import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/di/locator.dart';
import '../viewmodel/profile_view_model.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final vm = context.read<ProfileViewModel>();
    final email = locator<AuthRepository>().currentUser?.email;
    if (email != null) {
      vm.loadUserByEmail(email).then((_) {
        if (mounted) {
          final user = vm.user;
          if (user != null) {
            _usernameController.text = user.username;
            _profilePicController.text = user.profilePicture;
            setState(() {});
          }
        }
      }).catchError((error) {
        debugPrint('Error loading user in ProfileView: $error');
        if (mounted) setState(() {});
      });
    }
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

    if (vm.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No user data'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;
        final scaffold = Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            elevation: 0,
            leading: isMobile
                ? Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
          ),
          drawer: isMobile
              ? Drawer(
                  child: ProfileSidebar(
                    onClose: () => Navigator.of(context).pop(),
                  ),
                )
              : null,
          body: SafeArea(
            child: isMobile
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: _ProfileDetails(
                      usernameController: _usernameController,
                      profilePicController: _profilePicController,
                      vm: vm,
                      user: user,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 260,
                        child: ProfileSidebar(
                          onClose: () {},
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return VerticalDivider(
                            width: 1,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          );
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _ProfileDetails(
                            usernameController: _usernameController,
                            profilePicController: _profilePicController,
                            vm: vm,
                            user: user,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
        return scaffold;
      },
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController profilePicController;
  final ProfileViewModel vm;
  final User user;

  const _ProfileDetails({
    required this.usernameController,
    required this.profilePicController,
    required this.vm,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Profile",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        ProfilePictureSection(
          controller: profilePicController,
        ),
        const SizedBox(height: 40),
        CustomTextField(
          label: "Username",
          controller: usernameController,
        ),
        const SizedBox(height: 32),
        GenresSection(user: user),
        const SizedBox(height: 40),
        SaveButton(
          onSave: () async {
            final updated = user.copyWith(
              username: usernameController.text,
              profilePicture: profilePicController.text,
              genres: user.genres,
            );
            await vm.updateUser(updated);
            
            // Reload dashboard user to reflect changes
            final email = locator<AuthRepository>().currentUser?.email;
            if (email != null && context.mounted) {
              try {
                final dashboardVm = context.read<DashboardViewModel>();
                await dashboardVm.loadUserByEmail(email);
              } catch (e) {
                debugPrint('Error reloading dashboard: $e');
              }
            }
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        )
      ],
    );
  }
}
