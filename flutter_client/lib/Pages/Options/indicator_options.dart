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
  var _superTrendCandlePart = '';
  var _superTrendCandlePartDefault = TextEditingValue();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    String cp = '';
    AppStaticData.CandleParts.forEach((key, value) {
      if (options['superTrendOptions']['candlePart'] != null && value == (options['superTrendOptions']['candlePart'] as int)) cp = key;
    });

    setState(() {
      _superTrendCandlePart = cp;
      _superTrendCandlePartDefault = TextEditingValue(text: cp);
      _atrPeriod.text = options['atr']['period'] ?? '';
      _atrPeriod.text = options['atrMultiplier'] ?? '';
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
    if (_atrPeriod.text == '') {
      App.showSnackBar(
        'Input fields are not completed',
        'Close',
        () {},
      );
      return;
    }

    if (_isSubmitting) return;

    String? backendUrl = await AppDataRepository.GetBackendUrl();
    if (backendUrl == null) {
      App.showSnackBar(
        'No URL provided',
        'Close',
        () {},
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    var data = {
      "Atr": {"Period": int.parse(_atrPeriod.text), "Source": "close"},
      "AtrMultiplier": int.parse(_atrMultiplier.text),
      "SuperTrend": {"Period": int.parse(_superTrendPeriod.text), "Multiplier": int.parse(_superTrendMultiplier.text), "CandlePart": AppStaticData.CandleParts[_superTrendCandlePart], "ChangeATRCalculationMethod": true}
    };

    http.Response res = await http.patch(Uri.parse(backendUrl + 'indicator-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});

    Map<String, dynamic> responseObject = jsonDecode(res.body) as Map<String, dynamic>;

    setState(() {
      if (res.statusCode == 200) {
        _setFields(responseObject);
        App.showSnackBar(
          'Successful',
          'Close',
          () {},
        );
      } else
        App.showSnackBar(
          responseObject['Message'] == null ? 'Error' : responseObject['Message'],
          'Close',
          () {},
        );
      _isSubmitting = false;
    });
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
          Divider(),
          Center(
            child: Text('Super Trend'),
          ),
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
          Autocomplete<String>(
            initialValue: _superTrendCandlePartDefault,
            optionsBuilder: (TextEditingValue textEditingValue) => AppStaticData.CandleParts.keys, //.where((candlePart) => candlePart.toLowerCase().contains(textEditingValue.text.toLowerCase())),
            onSelected: (String selection) => _superTrendCandlePart = selection,
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onEditingComplete: onFieldSubmitted,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: "Super Trend Source",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
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
