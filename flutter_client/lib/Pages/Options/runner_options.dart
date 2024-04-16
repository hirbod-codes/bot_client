import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class RunnerOptions extends StatefulWidget {
  const RunnerOptions({super.key});

  @override
  State<RunnerOptions> createState() => _RunnerOptionsState();
}

class _RunnerOptionsState extends State<RunnerOptions> {
  String? _timeFrame = AppStaticData.timeFrames.keys.first;
  final _historicalCandlesCount = TextEditingController();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    String tf = '';
    AppStaticData.timeFrames.forEach((key, value) {
      if (options['timeFrame'] != null && value == (options['timeFrame'] as int)) tf = key;
    });

    setState(() {
      _timeFrame = tf;
      _historicalCandlesCount.text = options['historicalCandlesCount']?.toString() ?? '';
    });
  }

  @override
  void initState() {
    SettingsPage.getOptions().then((options) {
      if (options == null) return;

      AppStaticData.getSharedPreferences().then((value) {
        _setFields((jsonDecode(options) as Map<String, dynamic>)['runnerOptions']);
      }).whenComplete(() {
        super.initState();
      });
    });
  }

  bool _isSubmitting = false;

  void _submit() async {
    String snackBarMessage = 'Error';

    try {
      if (_timeFrame == '' || _historicalCandlesCount.text == '') {
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

      var data = {"TimeFrame": AppStaticData.timeFrames[_timeFrame], "HistoricalCandlesCount": int.parse(_historicalCandlesCount.text)};

      http.Response res = await http.patch(Uri.parse('${backendUrl}runner-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType, HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

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
  Widget build(BuildContext context) {
    var space = const SizedBox(
      width: 10,
      height: 35,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          TextField(
            controller: _historicalCandlesCount,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Number of stored historical Candles",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
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
                      ));
                })
                .values
                .toList(),
            onChanged: (a) => setState(() => _timeFrame = a),
          ),
          space,
          const SizedBox(
            height: 70,
            width: 10,
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
        ],
      ),
    );
  }
}
