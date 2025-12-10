import 'package:flutter/material.dart';

class ProfilePictureSection extends StatelessWidget {
  const ProfilePictureSection({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // 1. Check if a valid image URL is provided
    final hasUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    return Row(
      children: [
        CircleAvatar(
          radius: 60,
          // 2. Use NetworkImage only if a valid URL exists
          backgroundImage: hasUrl ? NetworkImage(imageUrl) : null,
          child: !hasUrl
              // 3. Show the placeholder icon if there is no URL
              ? const Icon(Icons.person, size: 60, color: Colors.grey)
              : null,
        ),
      ],
    );
  }
}
