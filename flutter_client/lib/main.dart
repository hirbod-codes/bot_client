import 'package:flutter/material.dart';
import 'package:flutter_client/Pages/home_page.dart';
import 'package:flutter_client/Pages/settings_page.dart';

void main() {
  runApp(const App());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key});

  static void showSnackBar(String content, String label, void Function() onPressed) => rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(content),
          action: SnackBarAction(
            label: label,
            onPressed: onPressed,
          ),
        ),
      );

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
