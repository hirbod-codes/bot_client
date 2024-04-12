import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class BotOptions extends StatefulWidget {
  const BotOptions({super.key});

  @override
  State<BotOptions> createState() => _BotOptionsState();
}

class _BotOptionsState extends State<BotOptions> {
  String? _timeFrame = AppStaticData.TimeFrames.keys.first;
  var _provider = TextEditingController();
  bool _shouldSkipOnParallelPositionRequest = false;
  var _retryCount = TextEditingController();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    String tf = '';
    AppStaticData.TimeFrames.forEach((key, value) {
      if (options['timeFrame'] != null && value == (options['timeFrame'] as int)) tf = key;
    });

    setState(() {
      _timeFrame = tf;
      _provider.text = options['provider'] ?? '';
      _shouldSkipOnParallelPositionRequest = options['shouldSkipOnParallelPositionRequest'] ?? '';
      _retryCount.text = options['retryCount']?.toString() ?? '';
    });
  }

  void initState() {
    SettingsPage.getOptions().then((options) {
      if (options == null) return;

      AppStaticData.getSharedPreferences().then((value) {
        _setFields((jsonDecode(options) as Map<String, dynamic>)['botOptions']);
      }).whenComplete(() {
        super.initState();
      });
    });
  }

  bool _isSubmitting = false;

  void _submit() async {
    String snackBarMessage = 'Error';

    try {
      if (_timeFrame == '' || _provider.text == '' || _retryCount.text == '') {
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

      var data = {"TimeFrame": AppStaticData.TimeFrames[_timeFrame], "Provider": _provider.text, "ShouldSkipOnParallelPositionRequest": _shouldSkipOnParallelPositionRequest, "RetryCount": int.parse(_retryCount.text)};

      http.Response res = await getClient().patch(Uri.parse(backendUrl + 'bot-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType, HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.BackendAuthKey) ?? ''});

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
            controller: _provider,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Provider Identifier",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
          Flexible(
            child: Wrap(
              direction: Axis.horizontal,
              children: [
                Text('Should Skip On Parallel Position Request'),
                Switch(
                  value: _shouldSkipOnParallelPositionRequest,
                  onChanged: (bool value) => setState(() => _shouldSkipOnParallelPositionRequest = value),
                ),
              ],
            ),
          ),
          space,
          Text('Time Frame'),
          DropdownButton(
            isExpanded: true,
            value: _timeFrame,
            elevation: 16,
            items: AppStaticData.TimeFrames.map<String, DropdownMenuItem<String>>((k, v) {
              return MapEntry(
                  k,
                  DropdownMenuItem<String>(
                    value: k,
                    child: Text(k),
                  ));
            }).values.toList(),
            onChanged: (a) => setState(() => _timeFrame = a),
          ),
          space,
          TextField(
            controller: _retryCount,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Number of attempts after failure",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
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
