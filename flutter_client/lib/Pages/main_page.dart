import 'package:flutter/material.dart';
import 'package:flutter_client/Pages/home_page.dart';
import 'package:flutter_client/Pages/order_history.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/Pages/wallet.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Widget _home = const HomePage();
  final Widget _settings = const SettingsPage();
  final Widget _orderHistory = const OrderHistory();
  final Widget _wallet = const Wallet();

  Widget? _content;

  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          items: const [
            BottomNavigationBarItem(icon: Icon(Symbols.home_sharp), label: 'Home', tooltip: 'Home'),
            BottomNavigationBarItem(icon: Icon(Symbols.settings_sharp), label: 'Settings', tooltip: 'Settings'),
            BottomNavigationBarItem(icon: Icon(Symbols.account_balance_wallet_sharp), label: 'Wallet', tooltip: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Symbols.history_sharp), label: 'Order history', tooltip: 'Order history'),
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
              case 2:
                setState(() {
                  _content = _wallet;
                  _index = index;
                });
                break;
              case 3:
                setState(() {
                  _content = _orderHistory;
                  _index = index;
                });
                break;
              default:
                setState(() {
                  _content = _home;
                  _index = index;
                });
            }
          },
        ),
        body: _content ?? _home,
      );
}
