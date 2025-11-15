import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gas_app_project_dev/firebase_options.dart';
import 'package:gas_app_project_dev/pages/signup_login_page.dart';
import 'package:gas_app_project_dev/services/globals.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "dev project", options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override State<MyApp> createState() => 
  _MyAppState();
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
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier = ValueNotifier<bool>(false),
      builder: (context, isDarkMode, child) {
    return MaterialApp(
      title: 'Gas Station App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light,),
       useMaterial3: true),
       darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark,),
        useMaterial3: true,
       ),
       themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(),
    );
      }
    );
  }
}
