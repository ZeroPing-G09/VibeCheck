import 'package:flutter/material.dart';

class ChangePictureDialog extends StatelessWidget {
  final TextEditingController controller;
  const ChangePictureDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Profile Picture'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Profile Picture URL',
          hintText: 'https://example.com/image.jpg',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
