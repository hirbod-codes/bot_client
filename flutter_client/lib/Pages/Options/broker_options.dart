import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class BrokerOptions extends StatefulWidget {
  const BrokerOptions({super.key});

  @override
  State<BrokerOptions> createState() => _BrokerOptionsState();
}

class _BrokerOptionsState extends State<BrokerOptions> {
  String? _timeFrame = AppStaticData.timeFrames.keys.first;

  final _symbol = TextEditingController();
  final _brokerCommission = TextEditingController();
  final _baseUrl = TextEditingController();
  final _apiKey = TextEditingController();
  final _apiSecret = TextEditingController();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null || !options.keys.contains('brokerOptions')) return;

    String tf = '';
    AppStaticData.timeFrames.forEach((key, value) {
      if (options["brokerOptions"]['timeFrame'] != null && value == (options["brokerOptions"]['timeFrame'] as int)) tf = key;
    });

    setState(() {
      _timeFrame = tf;

      _symbol.text = options["brokerOptions"]['symbol'] ?? '';
      _brokerCommission.text = options["brokerOptions"]['brokerCommission']?.toString() ?? '';
      _baseUrl.text = options["brokerOptions"]['baseUrl'] ?? '';
      _apiKey.text = options["brokerOptions"]['apiKey'] ?? '';
      _apiSecret.text = options["brokerOptions"]['apiSecret'] ?? '';
    });
  }

  bool _isSubmitting = false;
  bool _isLoading = false;

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
      if (_timeFrame == '' || _symbol.text == '' || _brokerCommission.text == '' || _baseUrl.text == '' || _apiKey.text == '' || _apiSecret.text == '') {
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
      data["brokerOptions"] = {
        "TimeFrame": AppStaticData.timeFrames[_timeFrame],
        "Symbol": _symbol.text,
        "BrokerCommission": double.parse(_brokerCommission.text),
        "BaseUrl": _baseUrl.text,
        "ApiKey": _apiKey.text,
        "ApiSecret": _apiSecret.text,
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
        if (snackBarMessage != '') {
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
        }

        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          (_isLoading || _isSubmitting) ? const Center(child: LinearProgressIndicator()) : null,
          TextField(
            controller: _symbol,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Symbol",
              hintText: "BTC-USDT",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _brokerCommission,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Commission",
              hintText: "0.001",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _baseUrl,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: "Base Url",
              hintText: "open-api-vst.bingx.com",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _apiKey,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: "API Key",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _apiSecret,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "API Secret",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          const Text('Time Frame'),
          DropdownButton(
            isExpanded: true,
            value: _timeFrame,
            elevation: 16,
            items: AppStaticData.timeFrames
                .map<String, DropdownMenuItem<String>>((k, v) {
                  return MapEntry(
                    k,
                    DropdownMenuItem<String>(
                      value: k,
                      child: Text(k),
                    ),
                  );
                })
                .values
                .toList(),
            onChanged: (a) => setState(() => _timeFrame = a),
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
