import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class Asset extends StatefulWidget {
  const Asset({super.key});

  @override
  State<Asset> createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  bool _isLoading = false;
  double? _equity;
  double? _availableMargin;
  double? _usedMargin;

  @override
  void initState() {
    super.initState();
    _getAssets();
  }

  Future<void> _getAssets() async {
    String snackBarMessage = 'Error';

    try {
      setState(() => _isLoading = true);

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      http.Response res = await http.get(Uri.parse('${backendUrl}assets/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      Map<String, dynamic>? assets = jsonDecode(res.body) as Map<String, dynamic>?;

      _equity = assets?['equity'] as double?;
      _availableMargin = assets?['availableMargin'] as double?;
      _usedMargin = assets?['usedMargin'] as double?;

      if (_equity != null && _availableMargin != null && _usedMargin != null) snackBarMessage = 'Successful';
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
      ? const Center(child: CircularProgressIndicator())
      : _equity == null || _availableMargin == null || _usedMargin == null
          ? Center(
              child: Wrap(
                children: [
                  const Icon(Icons.dangerous_outlined),
                  const Text('System failed to fetch assets.'),
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
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ...[
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        const Text('Balance:'),
                        Text(_equity?.toStringAsFixed(4) ?? 'NAN'),
                      ],
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        const Text('Available Margin:'),
                        Text(_availableMargin?.toStringAsFixed(4) ?? 'NAN'),
                      ],
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        const Text('Used Margin:'),
                        Text(_usedMargin?.toStringAsFixed(4) ?? 'NAN'),
                      ],
                    ),
                  ].map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: e,
                      ),
                    ),
                  ),
                ],
              ),
            );
}
