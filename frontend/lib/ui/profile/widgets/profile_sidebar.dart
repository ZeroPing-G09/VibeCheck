import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/di/locator.dart';
import '../viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfileSidebar extends StatelessWidget {
  final VoidCallback? onClose;

  const ProfileSidebar({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _navItem(context, "My Profile", Icons.person_outline, true,
              onTap: () {
            onClose?.call();
          }),
          const Spacer(),
          _navItem(
            context,
            "Logout",
            Icons.logout_outlined,
            false,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext ctx, String title, IconData icon, bool selected,
      {VoidCallback? onTap}) {
    final theme = Theme.of(ctx);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: selected 
          ? (isDark ? Colors.grey[800] : Colors.grey[200])
          : null,
      child: ListTile(
        leading: Icon(icon,
            color: selected 
                ? theme.primaryColor 
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    onClose?.call();
    await locator<AuthRepository>().signOut();
    if (context.mounted) {
      context.read<ProfileViewModel>().clear();
      AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRouter.loginRoute,
        (route) => false,
      );
    }
  }
}
