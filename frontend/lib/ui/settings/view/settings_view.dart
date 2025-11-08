import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../viewmodel/theme_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Center(
            child: const Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.brightness_6_outlined),
            value: themeViewModel.isDarkMode,
            onChanged: (val) => themeViewModel.toggleTheme(val),
          ),


          const Divider(),

          // NOTE: astea is puse la misto, poate punem mai tz altele
          SwitchListTile(
            title: const Text('Notifications'),
            value: notifications,
            onChanged: (val) => setState(() => notifications = val),
          ),
          const ListTile(title: Text('Privacy'), trailing: Text('Standard')),
          ListTile(
            title: Text('Language'),
            trailing: DropdownButton<String>(
              value: 'English',
              items: [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                DropdownMenuItem(value: 'French', child: Text('French')),
              ],
              onChanged: (val) {
                // todo
              },
            ),
          ),
        ],
      ),
    );
  }
}
