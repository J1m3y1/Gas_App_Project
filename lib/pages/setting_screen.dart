import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const SettingsPage({ super.key, required this.toggleTheme, required this.isDarkMode,});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool localdarkMode = false;
  bool notifications = false;
  String textSize = 'Medium';
  String language = 'English';

  @override void initState() {
    super.initState();
    localdarkMode = !widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          // Appearance Settings
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: localdarkMode,
            onChanged: (value) {setState(() { 
              localdarkMode = value;
              });
              widget.toggleTheme();
  },
          ),
          const SizedBox(height: 8),
          Text('Text Size'),
          DropdownButton<String>(
            value: textSize,
            isExpanded: true,
            items: ['Small', 'Medium', 'Large']
                .map((size) => DropdownMenuItem(value: size, child: Text(size)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => textSize = value);
            }
          ),

          const SizedBox(height: 8),
          Text('Language'),
          DropdownButton<String>(
            value: language,
            isExpanded: true,
            items: ['English', 'Spanish', 'French']
                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => language = value);
            }
          ),

          const SizedBox(height: 24),

          // Notification Settings
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            secondary: const Icon(Icons.notifications),
            value: notifications,
            onChanged: (value) => setState(() => notifications = value),
          ),
          const SizedBox(height: 24),
          const Divider(),

          Text(
            'Support/About',
              style: Theme.of(context).textTheme.titleLarge,
            ),

          // Feedback/Acknowledgments
          ListTile(
            title: const Text('Feedback'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {

            }
          ),
          ListTile(
            title: const Text('Acknowledgments'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {

            }
          ),
        ],
      ),
    );
  }
}