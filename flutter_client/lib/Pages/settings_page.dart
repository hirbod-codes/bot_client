import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/Options/bot_options.dart';
import 'package:flutter_client/Pages/Options/broker_options.dart';
import 'package:flutter_client/Pages/Options/indicator_options.dart';
import 'package:flutter_client/Pages/Options/risk_management_options.dart';
import 'package:flutter_client/Pages/Options/runner_options.dart';
import 'package:flutter_client/Pages/Options/security_options.dart';
import 'package:flutter_client/Pages/Options/strategy_options.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';

import '../Themes/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Future<String?> getOptions() async {
    try {
      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) return null;
      await Future.delayed(const Duration(seconds: 1));
      return (await http.get(Uri.parse('${backendUrl}options/'), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType, HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''})).body;
    } catch (e) {
      return null;
    }
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _content = const BrokerOptions();

  String _title = 'Broker Options';

  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    AppStaticData.getSharedPreferences().then((value) => value.setString(AppDataKeys.options, ''));
    SettingsPage.getOptions();
  }

  final Icon _lightIcon = const Icon(Symbols.light_mode_sharp);
  final Icon _darkIcon = const Icon(Symbols.dark_mode_sharp);
  Icon _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? const Icon(Symbols.light_mode_sharp) : const Icon(Symbols.dark_mode_sharp);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_title),
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
                  setState(() {
                    _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? _lightIcon : _darkIcon;
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: _refreshing ? const CircularProgressIndicator() : const Icon(Symbols.refresh_sharp),
            onPressed: () {
              setState(() {
                _refreshing = true;
              });
              SettingsPage.getOptions().then((value) async {
                if (value == null) return;

                (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.options, value);
              }).whenComplete(() => setState(() {
                    _refreshing = false;
                  }));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Icon(
                Symbols.phone_android,
                size: 48,
              ),
            ),
            ListTile(
              leading: const Icon(Symbols.storefront_sharp),
              title: const Text('Broker'),
              onTap: () {
                setState(() {
                  _title = 'Broker';
                  _content = const BrokerOptions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.science_sharp),
              title: const Text('Bot'),
              onTap: () {
                setState(() {
                  _title = 'Bot';
                  _content = const BotOptions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.radar_sharp),
              title: const Text('Strategy'),
              onTap: () {
                setState(() {
                  _title = 'Strategy';
                  _content = const StrategyOptions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.analytics_sharp),
              title: const Text('Indicator'),
              onTap: () {
                setState(() {
                  _title = 'Indicator';
                  _content = const IndicatorOptions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.attach_money_sharp),
              title: const Text('Risk Management'),
              onTap: () {
                setState(() {
                  _title = 'Risk Management';
                  _content = const RiskManagementOptions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.manage_accounts_sharp),
              title: const Text('Runner'),
              onTap: () {
                setState(() {
                  _title = 'Runner';
                  _content = const RunnerOptions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.security_sharp),
              title: const Text('Security'),
              onTap: () {
                setState(() {
                  _title = 'Security';
                  _content = const SecurityOptions();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _content,
    );
  }
}
