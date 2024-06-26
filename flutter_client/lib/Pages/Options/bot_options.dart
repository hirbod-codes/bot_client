import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class BotOptions extends StatefulWidget {
  const BotOptions({super.key});

  @override
  State<BotOptions> createState() => _BotOptionsState();
}

class _BotOptionsState extends State<BotOptions> {
  String? _timeFrame = AppStaticData.timeFrames.keys.first;
  final _provider = TextEditingController();
  bool _shouldSkipOnParallelPositionRequest = false;
  final _retryCount = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  void _setFields(Map<String, dynamic>? options) {
    if (options == null || !options.keys.contains('botOptions')) return;

    String tf = '';
    AppStaticData.timeFrames.forEach((key, value) {
      if (options["botOptions"]['timeFrame'] != null && value == (options["botOptions"]['timeFrame'] as int)) tf = key;
    });

    setState(() {
      _timeFrame = tf;
      _provider.text = options["botOptions"]['provider'] ?? '';
      _shouldSkipOnParallelPositionRequest = options["botOptions"]['shouldSkipOnParallelPositionRequest'] ?? '';
      _retryCount.text = options["botOptions"]['retryCount']?.toString() ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    try {
      SettingsPage.getOptions().then((options) {
        if (options == null) return;

        _setFields((jsonDecode(options) as Map<String, dynamic>));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    String snackBarMessage = 'Error';

    try {
      if (_timeFrame == '' || _provider.text == '' || _retryCount.text == '') {
        snackBarMessage = 'Input fields are not completed';
        return;
      }

      if (_isSubmitting) return;

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided';
        return;
      }

      setState(() => _isSubmitting = true);

      var data = jsonDecode(await SettingsPage.getOptions() ?? '{}') as Map<String, dynamic>;
      data["botOptions"] = {
        "TimeFrame": AppStaticData.timeFrames[_timeFrame],
        "Provider": _provider.text,
        "ShouldSkipOnParallelPositionRequest": _shouldSkipOnParallelPositionRequest,
        "RetryCount": int.parse(_retryCount.text),
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
          TextField(
            controller: _provider,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Provider Identifier",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: [
              const Text('Should Skip On Parallel Position Request'),
              Switch(
                value: _shouldSkipOnParallelPositionRequest,
                onChanged: (bool value) => setState(() => _shouldSkipOnParallelPositionRequest = value),
              ),
            ],
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
                      ));
                })
                .values
                .toList(),
            onChanged: (a) => setState(() => _timeFrame = a),
          ),
          TextField(
            controller: _retryCount,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Number of attempts after failure",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
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
