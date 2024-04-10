import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class IndicatorOptions extends StatefulWidget {
  const IndicatorOptions({super.key});

  @override
  State<IndicatorOptions> createState() => _IndicatorOptionsState();
}

class _IndicatorOptionsState extends State<IndicatorOptions> {
  var _atrPeriod = TextEditingController();
  var _atrMultiplier = TextEditingController();
  var _superTrendPeriod = TextEditingController();
  var _superTrendMultiplier = TextEditingController();
  String? _superTrendCandlePart = AppStaticData.CandleParts.keys.first;

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    String cp = '';
    AppStaticData.CandleParts.forEach((key, value) {
      if (options['superTrendOptions']['candlePart'] != null && value == (options['superTrendOptions']['candlePart'] as int)) cp = key;
    });

    setState(() {
      _superTrendCandlePart = cp;

      _atrPeriod.text = options['atr']['period']?.toString() ?? '';
      _atrMultiplier.text = options['atrMultiplier']?.toString() ?? '';
      _superTrendPeriod.text = options['superTrendOptions']['period']?.toString() ?? '';
      _superTrendMultiplier.text = options['superTrendOptions']['multiplier']?.toString() ?? '';
    });
  }

  void initState() {
    SettingsPage.getOptions().then((options) {
      if (options == null) return;

      AppStaticData.getSharedPreferences().then((value) {
        _setFields((jsonDecode(options) as Map<String, dynamic>)['indicatorOptions']);
      }).whenComplete(() {
        super.initState();
      });
    });
  }

  bool _isSubmitting = false;

  void _submit() async {
    String snackBarMessage = 'Error';

    try {
      if (_atrPeriod.text == '' || _atrMultiplier.text == '' || _superTrendMultiplier.text == '' || _superTrendPeriod.text == '' || _superTrendCandlePart == '') {
        snackBarMessage = 'Input fields are not completed';
        return;
      }

      if (_isSubmitting) return;

      String? backendUrl = await AppDataRepository.GetBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided';
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      var data = {
        "Atr": {"Period": int.parse(_atrPeriod.text), "Source": "close"},
        "AtrMultiplier": double.parse(_atrMultiplier.text),
        "SuperTrendOptions": {"Period": int.parse(_superTrendPeriod.text), "Multiplier": double.parse(_superTrendMultiplier.text), "CandlePart": AppStaticData.CandleParts[_superTrendCandlePart], "ChangeATRCalculationMethod": true}
      };

      http.Response res = await http.patch(Uri.parse(backendUrl + 'indicator-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});

      Map<String, dynamic>? responseObject = null;
      if (res.body != '') responseObject = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        snackBarMessage = 'Successful';
        if (res.body != '') _setFields(responseObject);
      } else
        snackBarMessage = responseObject?['Message'] ?? 'Error';
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
  Widget build(BuildContext context) {
    var space = SizedBox(
      width: 10,
      height: 35,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Center(
            child: Text('ATR'),
          ),
          Divider(),
          TextField(
            controller: _atrPeriod,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "ATR Period",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
          TextField(
            controller: _atrMultiplier,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "ATR Multiplier",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
          space,
          Center(
            child: Text('Super Trend'),
          ),
          Divider(),
          TextField(
            controller: _superTrendPeriod,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Super Trend Period",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
          TextField(
            controller: _superTrendMultiplier,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Super Trend Multiplier",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
          DropdownButton(
            isExpanded: true,
            value: _superTrendCandlePart,
            elevation: 16,
            items: AppStaticData.CandleParts.map<String, DropdownMenuItem<String>>((k, v) {
              return MapEntry(
                  k,
                  DropdownMenuItem<String>(
                    value: k,
                    child: Text(k),
                  ));
            }).values.toList(),
            onChanged: (a) => setState(() => _superTrendCandlePart = a),
          ),
          space,
          SizedBox(
            height: 70,
            width: 10,
          ),
          ElevatedButton(
              onPressed: _submit,
              child: _isSubmitting
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    )
                  : Text('Update')),
        ],
      ),
    );
  }
}
