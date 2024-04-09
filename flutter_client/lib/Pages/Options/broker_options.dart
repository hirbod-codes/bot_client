import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class BrokerOptions extends StatefulWidget {
  const BrokerOptions({super.key});

  @override
  State<BrokerOptions> createState() => _BrokerOptionsState();
}

class _BrokerOptionsState extends State<BrokerOptions> {
  String _timeFrame = '';
  var _timeFrameDefault = TextEditingValue(text: '');

  var _symbol = TextEditingController();
  var _brokerCommission = TextEditingController();
  var _baseUrl = TextEditingController();
  var _apiKey = TextEditingController();
  var _apiSecret = TextEditingController();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    String tf = '';
    AppStaticData.TimeFrames.forEach((key, value) {
      if (options['timeFrame'] != null && value == (options['timeFrame'] as int)) tf = key;
    });

    setState(() {
      _timeFrame = tf;
      _timeFrameDefault = TextEditingValue(text: tf);

      _symbol.text = options['symbol'] ?? '';
      _brokerCommission.text = options['brokerCommission']?.toString() ?? '';
      _baseUrl.text = options['baseUrl'] ?? '';
      _apiKey.text = options['apiKey'] ?? '';
      _apiSecret.text = options['apiSecret'] ?? '';
    });
  }

  bool _isSubmitting = false;

  void initState() {
    SettingsPage.getOptions().then((options) {
      if (options == null) return;

      AppStaticData.getSharedPreferences().then((value) {
        _setFields((jsonDecode(options) as Map<String, dynamic>)['brokerOptions']);
      }).whenComplete(() {
        super.initState();
      });
    });
  }

  void _submit() async {
    String snackBarMessage = 'Error';

    try {
      if (_timeFrame == '' || _symbol.text == '' || _brokerCommission.text == '' || _baseUrl.text == '' || _apiKey.text == '' || _apiSecret.text == '') {
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

      var data = {"TimeFrame": AppStaticData.TimeFrames[_timeFrame], "Symbol": _symbol.text, "BrokerCommission": double.parse(_brokerCommission.text), "BaseUrl": _baseUrl.text, "ApiKey": _apiKey.text, "ApiSecret": _apiSecret.text};

      http.Response res = await http.patch(Uri.parse(backendUrl + 'broker-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});

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
          TextField(
            controller: _symbol,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
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
          space,
          TextField(
            controller: _brokerCommission,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
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
          space,
          TextField(
            controller: _baseUrl,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
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
          space,
          TextField(
            controller: _apiKey,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "API Key",
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
            controller: _apiSecret,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "API Secret",
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
            initialValue: _timeFrameDefault,
            optionsBuilder: (TextEditingValue textEditingValue) => AppStaticData.TimeFrames.keys.where((timeFrame) => timeFrame.toLowerCase().contains(textEditingValue.text.toLowerCase())),
            onSelected: (String selection) => _timeFrame = selection,
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onEditingComplete: onFieldSubmitted,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: "Time Frame",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
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
