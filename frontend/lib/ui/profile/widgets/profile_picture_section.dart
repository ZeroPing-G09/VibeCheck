import 'package:flutter/material.dart';
import 'package:frontend/ui/profile/dialogs/change_picture_dialog.dart';

class ProfilePictureSection extends StatelessWidget {
  final TextEditingController controller;
  const ProfilePictureSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // 1. Check if the controller has text (i.e., a URL has been loaded)
    final hasUrl =
        controller.text.isNotEmpty && controller.text.startsWith('http');

    return Row(
      children: [
        CircleAvatar(
          radius: 60,
          // 2. Use NetworkImage only if a valid URL exists
          backgroundImage: hasUrl ? NetworkImage(controller.text) : null,
          child: !hasUrl
              // 3. Show the placeholder icon if there is no URL
              ? const Icon(Icons.person, size: 60, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ChangePictureDialog(controller: controller),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3748),
              ),
              child: const Text("Change Picture"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => controller.clear(),
              child: const Text("Delete Picture"),
            ),
          ],
        ),
      ],
    );
  }
}
