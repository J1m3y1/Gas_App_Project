import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  title: 'Gas Station App',
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,brightness: Brightness.light,)
  ,useMaterial3: true,
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,brightness: Brightness.dark,),
    useMaterial3: true,
  ),
  themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
  home: MainNavigation(toggleTheme: toggleTheme,isDarkMode: isDarkMode,),
);
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainNavigation({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      MapScreen(isDarkMode: widget.isDarkMode),
      const SearchScreen(),
      SettingsPage(toggleTheme: widget.toggleTheme, isDarkMode: true,),
    ];

    return Scaffold(
      body: IndexedStack(
        index: myIndex,
        children: screens,
      ),
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
}
