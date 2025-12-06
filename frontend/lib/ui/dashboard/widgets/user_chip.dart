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
              backgroundImage: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                  ? NetworkImage(imageUrl)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: imageUrl.isEmpty || !imageUrl.startsWith('http')
                  ? Icon(Icons.person, size: 14, color: Colors.grey.shade600)
                  : null,
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
