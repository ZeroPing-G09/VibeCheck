import 'package:flutter/material.dart';
import '../dialogs/change_picture_dialog.dart';

class ProfilePictureSection extends StatelessWidget {
  final TextEditingController controller;
  const ProfilePictureSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasUrl = controller.text.startsWith('http');
    return Row(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: hasUrl ? NetworkImage(controller.text) : null,
          child: !hasUrl
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3748)),
              child: const Text("Change Picture"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => controller.clear(),
              child: const Text("Delete Picture"),
            ),
          ],
        )
      ],
    );
  }
}
