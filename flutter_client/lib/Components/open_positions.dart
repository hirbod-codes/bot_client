import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Components/open_position.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class OpenPositions extends StatefulWidget {
  const OpenPositions({super.key});

  @override
  State<OpenPositions> createState() => _OpenPositionsState();
}

class _OpenPositionsState extends State<OpenPositions> {
  bool _isLoading = false;

  Map<String, List<dynamic>>? _positions;

  String? _timeFrame;

  @override
  void initState() {
    super.initState();
    _getPositions();
  }

  void _getPositions() async {
    if (_isLoading) return;

    String snackBarMessage = '';
    try {
      setState(() => _isLoading = false);

      String? optionsJson = await SettingsPage.getOptions();
      if (optionsJson == null || optionsJson.isEmpty) {
        snackBarMessage = 'No options provided.';
        return;
      }
      var options = jsonDecode(optionsJson) as Map<String, dynamic>;
      AppStaticData.timeFrames.forEach((key, value) {
        if (options["brokerOptions"]['timeFrame'] != null && value == (options["brokerOptions"]['timeFrame'] as int)) _timeFrame = key;
      });

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      var res = await http.get(Uri.parse('${backendUrl}open-positions/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      if (res.statusCode != 200) {
        snackBarMessage = 'Error';
        return;
      }

      List positions = jsonDecode(res.body) as List<dynamic>;

      for (var position in positions) {
        _positions ??= {};
        _positions![position['symbol']] ??= [];

        _positions![position['symbol']]!.add({
          'id': position['id'],
          'openedPrice': position['openedPrice'],
          'commission': position['commission'],
          'profit': position['profit'],
          'margin': position['margin'],
          'leverage': position['leverage'],
          'positionDirection': position['positionDirection'],
          'createdAt': (position['createdAt'] ?? '').replaceAll(RegExp('T'), ' '),
          'openedAt': (position['openedAt'] ?? '').replaceAll(RegExp('T'), ' '),
        });
      }
    } finally {
      setState(() {
        _isLoading = false;

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

  @override
  Widget build(BuildContext context) => _isLoading
      ? const CircularProgressIndicator()
      : _timeFrame == null || _positions == null || _positions!.isEmpty
          ? Center(
              child: Wrap(
                children: [
                  const Icon(Icons.dangerous_outlined),
                  const Text('No open positions'),
                ]
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: e,
                      ),
                    )
                    .toList(),
              ),
            )
          : DefaultTabController(
              length: _positions!.keys.length,
              child: Column(
                children: [
                  TabBar(
                    tabs: _positions!.entries.map((e) => Text(e.key)).toList(),
                  ),
                  SizedBox(
                    height: double.maxFinite,
                    child: TabBarView(
                      children: _positions!.entries.map((e) => OpenPosition(positions: e.value, symbol: e.key, timeFrame: _timeFrame!)).toList(),
                    ),
                  ),
                ],
              ),
            );
}
