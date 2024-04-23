import 'package:flutter_client/Pages/wallet/asset.dart';
import 'package:flutter_client/Pages/wallet/pnl.dart';
import 'package:flutter_client/Themes/theme.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final Icon _lightIcon = const Icon(Icons.light_mode_outlined);
  final Icon _darkIcon = const Icon(Icons.dark_mode_outlined);
  Icon _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? const Icon(Icons.light_mode_outlined) : const Icon(Icons.dark_mode_outlined);

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        actions: [
          SizedBox(
            height: 70,
            width: 70,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Switch(
                inactiveTrackColor: Theme.of(context).colorScheme.secondaryContainer,
                key: ValueKey<Icon>(_themeSwitchIcon),
                thumbIcon: MaterialStateProperty.all(_themeSwitchIcon),
                value: customTheme.themeMode == ThemeMode.light,
                onChanged: (bool value) {
                  customTheme.toggleTheme();
                  setState(() => _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? _lightIcon : _darkIcon);
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: const [
          Asset(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(),
          ),
          Center(child: Text('Transactions')),
          Pnl(),
        ],
      ));
}
