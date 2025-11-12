import 'package:flutter/material.dart';
import '../dialogs/logout_dialog.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          _navItem(context, "My Profile", Icons.person_outline, true),
          const Spacer(),
          _navItem(context, "Logout", Icons.logout_outlined, false, onTap: () {
            showDialog(context: context, builder: (_) => const LogoutDialog());
          }),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext ctx, String title, IconData icon, bool selected,
      {VoidCallback? onTap}) {
    return Container(
      color: selected ? Colors.grey[100] : null,
      child: ListTile(
        leading: Icon(icon,
            color:
                selected ? Theme.of(ctx).primaryColor : Colors.grey.shade600),
        title: Text(title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
        onTap: onTap,
      ),
    );
  }
}
