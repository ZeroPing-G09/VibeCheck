import 'package:flutter/material.dart';

class UserChip extends StatelessWidget {
  final String username;
  final String imageUrl;
  final void Function(String value) onActionSelected;

  const UserChip({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onActionSelected,
      offset: const Offset(0, 44),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('My profile')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 8),
            Text(username, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
