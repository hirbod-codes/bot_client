import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Components/open_positions.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/Themes/theme.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget Function(dynamic context) _status = (context) => const Icon(Icons.question_mark_outlined);

  bool _loading = false;

  bool _isSubmitting = false;

  String _selectedStatus = "";

  String? _fullName;
  String? _brokerName;

  void _start() => _submit('start');

  void _suspend() => _submit('suspend');

  void _stop() => _submit('stop');

  void _getStatus() async {
    if (_loading) return;

    bool wasSuccessful = false;
    String snackBarMessage = '';
    try {
      setState(() {
        _loading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      var res = await http.get(Uri.parse('${backendUrl}status/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      if (res.statusCode == 200) {
        wasSuccessful = true;
        snackBarMessage = 'Successful';
        setState(() {
          if (res.body != '') _status = (context) => Text(jsonDecode(res.body)['status'], style: Theme.of(context).textTheme.titleLarge);
          switch (jsonDecode(res.body)['status']) {
            case 'RUNNING':
              _selectedStatus = 'start';
              break;
            case 'SUSPENDED':
              _selectedStatus = 'suspend';
              break;
            case 'STOPPED':
              _selectedStatus = 'stop';
              break;
            default:
          }
        });
        return;
      }
      snackBarMessage = 'Error';
    } finally {
      setState(() {
        _loading = false;

        if (!wasSuccessful) {
          _status = (context) => FloatingActionButton(
                onPressed: _getStatus,
                child: const Icon(Symbols.refresh_sharp),
              );
        }

        if (snackBarMessage != '') {
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
        }
      });
    }
  }

  void _submit(String action) async {
    if (_isSubmitting) return;

    bool wasSuccessful = false;
    String snackBarMessage = 'Error';
    try {
      setState(() {
        _isSubmitting = true;
      });

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null || !['start', 'suspend', 'stop'].contains(action)) {
        snackBarMessage = 'No URL provided.';
        return;
      }

      http.Response res = await http.post(Uri.parse("$backendUrl$action/"), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      Map<String, dynamic>? responseObject;
      if (res.body != '') responseObject = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        wasSuccessful = true;
        snackBarMessage = 'Successful';
      } else {
        snackBarMessage = responseObject?['message'] ?? 'Error';
      }
    } finally {
      _getStatus();
      setState(() {
        _isSubmitting = false;
        if (wasSuccessful) {
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    String? optionsJson = await SettingsPage.getOptions();
    if (optionsJson == null) return;
    Map<String, dynamic> options = jsonDecode(optionsJson) as Map<String, dynamic>;
    _fullName = options[AppDataKeys.fullName];
    _brokerName = options[AppDataKeys.brokerName];

    setState(() {});

    _getStatus();
  }

  final Icon _lightIcon = const Icon(Symbols.light_mode_sharp);
  final Icon _darkIcon = const Icon(Symbols.dark_mode_sharp);
  Icon _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? const Icon(Symbols.light_mode_sharp) : const Icon(Symbols.dark_mode_sharp);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: _fullName == null
              ? null
              : Row(
                  children: [
                    const CircleAvatar(child: Icon(Symbols.account_circle_sharp)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fullName!.contains('-') ? Text('${_fullName!.split('-')[0]} ${_fullName!.split('-')[1]}') : Text(_fullName!),
                          Text(
                            _brokerName!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          actions: [
            AnimatedSwitcher(
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
            IconButton(
              onPressed: _getStatus,
              icon: const Icon(Symbols.refresh_sharp),
            ),
          ],
        ),
        body: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 8.0),
              child: Text('Status'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (_loading || _isSubmitting) ? const Center(child: CircularProgressIndicator()) : _status(context),
            ),
            const SizedBox(
              height: 30,
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) => constraints.maxWidth > 340
                  ? Center(
                      child: SegmentedButton(
                        showSelectedIcon: false,
                        emptySelectionAllowed: true,
                        segments: const [
                          ButtonSegment(enabled: true, value: 'start', label: Text('Start'), icon: Icon(Symbols.play_arrow_sharp)),
                          ButtonSegment(enabled: true, value: 'suspend', label: Text('Suspend'), icon: Icon(Symbols.pause_sharp)),
                          ButtonSegment(enabled: true, value: 'stop', label: Text('Stop'), icon: Icon(Symbols.stop_sharp)),
                        ],
                        selected: <String>{_selectedStatus},
                        onSelectionChanged: (s) {
                          switch (s.first) {
                            case 'start':
                              _start();
                              break;
                            case 'suspend':
                              _suspend();
                              break;
                            case 'stop':
                              _stop();
                              break;
                            default:
                          }
                          setState(() {
                            _selectedStatus = s.first;
                          });
                        },
                      ),
                    )
                  : Center(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          FilledButton(
                            onPressed: _start,
                            child: const Wrap(
                              direction: Axis.horizontal,
                              children: [
                                Icon(Icons.play_arrow_outlined),
                                Text('Start'),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          FilledButton(
                            onPressed: _suspend,
                            child: const Wrap(
                              direction: Axis.horizontal,
                              children: [
                                Icon(Icons.pause_outlined),
                                Text('Suspend'),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          FilledButton(
                            onPressed: _stop,
                            child: const Wrap(
                              direction: Axis.horizontal,
                              children: [
                                Icon(Icons.stop_outlined),
                                Text('Stop'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const Divider(),
            const OpenPositions(),
          ],
        ),
      );
}
