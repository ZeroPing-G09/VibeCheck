import 'package:flutter/material.dart';

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
      ],
    );
  }
}
