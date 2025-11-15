import 'package:flutter/material.dart';
import 'package:gas_app_project_dev/pages/map_screen.dart';
import 'package:gas_app_project_dev/pages/search_screen.dart';
import 'package:gas_app_project_dev/pages/setting_screen.dart';
import 'package:gas_app_project_dev/services/globals.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, _){
    final screens = [
    MapScreen(isDarkMode: isDarkMode, key: ValueKey(isDarkMode)),
    SearchScreen(isDarkMode: isDarkMode),
    SettingsPage(),
  ];
  print("MainNavigation → isDarkMode = ${isDarkMode}");

    return Scaffold(
      body: screens[myIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
    );
  }
}