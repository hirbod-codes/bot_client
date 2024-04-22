import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class IndicatorOptions extends StatefulWidget {
  const IndicatorOptions({super.key});

  @override
  State<IndicatorOptions> createState() => _IndicatorOptionsState();
}

class _IndicatorOptionsState extends State<IndicatorOptions> {
  final _atrPeriod = TextEditingController();
  final _atrMultiplier = TextEditingController();
  final _superTrendPeriod = TextEditingController();
  final _superTrendMultiplier = TextEditingController();
  String? _superTrendCandlePart = AppStaticData.candleParts.keys.first;

  bool _isLoading = false;
  bool _isSubmitting = false;

  void _setFields(Map<String, dynamic>? options) {
    if (options == null || !options.keys.contains('indicatorOptions')) return;

    String cp = '';
    AppStaticData.candleParts.forEach((key, value) {
      if (options["indicatorOptions"]['superTrendOptions']['candlePart'] != null && value == (options["indicatorOptions"]['superTrendOptions']['candlePart'] as int)) cp = key;
    });

    setState(() {
      _superTrendCandlePart = cp;

      _atrPeriod.text = options["indicatorOptions"]['atr']['period']?.toString() ?? '';
      _atrMultiplier.text = options["indicatorOptions"]['atrMultiplier']?.toString() ?? '';
      _superTrendPeriod.text = options["indicatorOptions"]['superTrendOptions']['period']?.toString() ?? '';
      _superTrendMultiplier.text = options["indicatorOptions"]['superTrendOptions']['multiplier']?.toString() ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    try {
      setState(() => _isLoading = true);
      SettingsPage.getOptions().then((options) {
        if (options == null) return;

        AppStaticData.getSharedPreferences().then((value) {
          _setFields((jsonDecode(options) as Map<String, dynamic>));
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    String snackBarMessage = 'Error';

    try {
      if (_atrPeriod.text == '' || _atrMultiplier.text == '' || _superTrendMultiplier.text == '' || _superTrendPeriod.text == '' || _superTrendCandlePart == '') {
        snackBarMessage = 'Input fields are not completed';
        return;
      }

      if (_isSubmitting) return;

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided';
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      var data = jsonDecode(await SettingsPage.getOptions() ?? '{}') as Map<String, dynamic>;
      data["indicatorOptions"] = {
        "Atr": {"Period": int.parse(_atrPeriod.text), "Source": "close"},
        "AtrMultiplier": double.parse(_atrMultiplier.text),
        "SuperTrendOptions": {"Period": int.parse(_superTrendPeriod.text), "Multiplier": double.parse(_superTrendMultiplier.text), "CandlePart": AppStaticData.candleParts[_superTrendCandlePart], "ChangeATRCalculationMethod": true}
      };

      http.Response res = await http.patch(Uri.parse('${backendUrl}options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType, HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      Map<String, dynamic>? responseObject;
      if (res.body != '') responseObject = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        snackBarMessage = 'Successful';
        if (res.body != '') _setFields(responseObject);
      } else {
        snackBarMessage = responseObject?['Message'] ?? 'Error';
      }
    } finally {
      setState(() {
        App.showSnackBar(
          snackBarMessage,
          'Close',
          () {},
        );

        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          (_isLoading || _isSubmitting) ? const Center(child: LinearProgressIndicator()) : null,
          const Center(
            child: Text('ATR'),
          ),
          const Divider(),
          TextField(
            controller: _atrPeriod,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "ATR Period",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _atrMultiplier,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "ATR Multiplier",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('Super Trend'),
          ),
          const Divider(),
          TextField(
            controller: _superTrendPeriod,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Super Trend Period",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _superTrendMultiplier,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Super Trend Multiplier",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          const Text('Source'),
          DropdownButton(
            isExpanded: true,
            value: _superTrendCandlePart,
            elevation: 16,
            items: AppStaticData.candleParts
                .map<String, DropdownMenuItem<String>>((k, v) {
                  return MapEntry(
                      k,
                      DropdownMenuItem<String>(
                        value: k,
                        child: Text(k),
                      ));
                })
                .values
                .toList(),
            onChanged: (a) => setState(() => _superTrendCandlePart = a),
          ),
          ElevatedButton(
              onPressed: _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Update')),
        ]
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: e,
              ),
            )
            .toList(),
      );
}
