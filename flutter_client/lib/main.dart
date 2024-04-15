import 'package:flutter/material.dart';
import 'package:flutter_client/Pages/home_page.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/Themes/theme.dart';

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
      home: const NavigatorPage(),
    );
  }
}

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  final Widget _home = const HomePage();
  final Widget _settings = const SettingsPage();

  Widget? _content;

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
            tooltip: 'Settings',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              setState(() {
                _content = _home;
                // _content = Container(
                //   decoration: BoxDecoration(
                //     gradient: RadialGradient(
                //       radius: 0.75,
                //       colors: [
                //         Colors.red,
                //         Colors.yellow,
                //         Theme.of(context).colorScheme.primary,
                //         Theme.of(context).colorScheme.secondary,
                //       ],
                //       stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
                //     ),
                //   ),
                //   child: _home,
                // );
                _index = index;
              });
              break;
            case 1:
              setState(() {
                _content = _settings;
                // _content = Container(
                //   decoration: BoxDecoration(
                //     gradient: RadialGradient(
                //       radius: 0.75,
                //       colors: [
                //         Theme.of(context).colorScheme.primary,
                //         Theme.of(context).colorScheme.secondary,
                //       ],
                //     ),
                //   ),
                //   child: _settings,
                // );
                _index = index;
              });
              break;
            default:
          }
        },
      ),
      body: _content ?? _home,
    );
  }
}
