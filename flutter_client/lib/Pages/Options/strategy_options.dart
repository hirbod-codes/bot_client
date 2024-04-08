import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class StrategyOptions extends StatefulWidget {
  const StrategyOptions({super.key});

  @override
  State<StrategyOptions> createState() => _StrategyOptionsState();
}

class _StrategyOptionsState extends State<StrategyOptions> {
  var _provider = TextEditingController();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    setState(() {
      _provider.text = options['provider'] ?? '';
    });
  }

  void initState() {
    SettingsPage.getOptions().then((options) {
      if (options == null) return;

      AppStaticData.getSharedPreferences().then((value) {
        _setFields((jsonDecode(options) as Map<String, dynamic>)['strategyOptions']);
      }).whenComplete(() {
        super.initState();
      });
    });
  }

  bool _isSubmitting = false;

  void _submit() async {
    if (_provider.text == '') {
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

    var data = {"Provider": int.parse(_provider.text)};

    http.Response res = await http.patch(Uri.parse(backendUrl + 'strategy-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});

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
          TextField(
            controller: _provider,
            keyboardType: TextInputType.number,
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
