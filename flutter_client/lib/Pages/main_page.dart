import 'package:flutter/material.dart';
import 'package:flutter_client/Pages/home_page.dart';
import 'package:flutter_client/Pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Widget _home = const HomePage();
  final Widget _settings = const SettingsPage();

  Widget? _content;

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.background,
          ],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  _index = index;
                });
                break;
              case 1:
                setState(() {
                  _content = _settings;
                  _index = index;
                });
                break;
              default:
            }
          },
        ),
        body: _content ?? _home,
      ),
    );
  }
}
