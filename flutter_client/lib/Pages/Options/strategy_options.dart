import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class StrategyOptions extends StatefulWidget {
  const StrategyOptions({super.key});

  @override
  State<StrategyOptions> createState() => _StrategyOptionsState();
}

class _StrategyOptionsState extends State<StrategyOptions> {
  final _providerName = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;

  void _setFields(Map<String, dynamic>? options) {
    if (options == null || !options.keys.contains('strategyOptions')) return;

    setState(() {
      _providerName.text = options["strategyOptions"]['providerName'] ?? '';
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
      if (_providerName.text == '') {
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
      data["strategyOptions"] = {
        "ProviderName": _providerName.text,
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
  Widget build(BuildContext context) {
    var space = const SizedBox(
      width: 10,
      height: 35,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          (_isLoading || _isSubmitting) ? const Center(child: LinearProgressIndicator()) : null,
          TextField(
            controller: _providerName,
            keyboardType: TextInputType.number,
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
