import 'package:flutter/material.dart';
import 'package:gas_app_project_dev/pages/acknowledgments_page.dart';
import 'package:gas_app_project_dev/pages/feedback_page.dart';
import 'package:gas_app_project_dev/pages/signup_login_page.dart';
import 'package:gas_app_project_dev/services/auth.dart';
import 'package:gas_app_project_dev/services/globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({ super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String textSize = 'Medium';

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
          ValueListenableBuilder<bool>(
            valueListenable: isDarkModeNotifier,
            builder: (context, value, _) {
          return SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: value,
            onChanged: (newValue) {
              isDarkModeNotifier.value = newValue;
  },
          );
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


          const SizedBox(height: 24),

          Text(
            'Support/About',
              style: Theme.of(context).textTheme.titleLarge,
            ),

          // Feedback/Acknowledgments
          ListTile(
            title: const Text('Apply To contribute'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );

            }
          ),
          ListTile(
            title: const Text('Acknowledgments'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcknowledgmentsPage(),
                ),
              );
            }
          ),
          ListTile(
            title:  const Text('Sign Out'),
            onTap: () async{
              try {
                await Auth().signOut();

                if(mounted){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to sign out. Try again.'))
                );
              }
            },
          )
        ],
      ),
    );
  }
}