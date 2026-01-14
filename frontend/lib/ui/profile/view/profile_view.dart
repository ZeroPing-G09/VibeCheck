import 'package:flutter/material.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:frontend/ui/profile/widgets/genres_section.dart';
import 'package:frontend/ui/profile/widgets/profile_picture_section.dart';
import 'package:frontend/ui/profile/widgets/profile_sidebar.dart';
import 'package:frontend/ui/profile/widgets/save_button.dart';
import 'package:provider/provider.dart';

/// The main profile view displaying user information and settings.
class ProfileView extends StatefulWidget {
  /// Creates a [ProfileView].
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final vm = context.read<ProfileViewModel>();
    final email = vm.currentUserEmail;
    if (email != null) {
      vm
          .loadUserByEmail(email)
          .then((_) {
            if (mounted) {
              final user = vm.user;
              if (user != null) {
                setState(() {});
              }
            }
          })
          .catchError((Object error) {
            debugPrint('Error loading user in ProfileView: $error');
            if (mounted) {
              setState(() {});
            }
          });
    }
    vm.loadAvailableGenres();
  }

  @override
  void dispose() {
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
        final isMobile = constraints.maxWidth < 900;
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: _ProfileDetails(vm: vm, user: user),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 260,
                        child: ProfileSidebar(onClose: () {}),
                      ),
                      Builder(
                        builder: (context) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return VerticalDivider(
                            width: 1,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          );
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _ProfileDetails(vm: vm, user: user),
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
  const _ProfileDetails({required this.vm, required this.user});
  final ProfileViewModel vm;
  final User user;

  Future<void> _handleSave(BuildContext context) async {
    final updated = user.copyWith(genres: user.genres);

    try {
      await vm.updateUser(updated);

      // Reload dashboard user to reflect changes
      final email = vm.currentUserEmail;
      if (email != null && context.mounted) {
        try {
          final dashboardVm = context.read<DashboardViewModel>();
          await dashboardVm.loadUserByEmail(email);
        } catch (e) {
          debugPrint('Error reloading dashboard: $e');
        }
      }

      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ProfilePictureSection(imageUrl: user.avatarUrl),
        const SizedBox(height: 32),
        GenresSection(
          user: user,
          enabled: vm.isServerAvailable,
        ),
        const SizedBox(height: 40),
        SaveButton(
          enabled: vm.isServerAvailable,
          onSave: () => _handleSave(context),
        ),
      ],
    );
  }
}
