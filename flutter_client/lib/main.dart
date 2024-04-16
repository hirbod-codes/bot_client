import 'package:flutter/material.dart';
import 'package:flutter_client/Pages/main_page.dart';
import 'package:flutter_client/Themes/theme.dart';

void main() => runApp(const App());

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
  @override
  void initState() {
    super.initState();
    customTheme.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Trading Bot',
      themeMode: customTheme.themeMode,
      theme: customTheme.customLightTheme,
      darkTheme: customTheme.customDarkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
