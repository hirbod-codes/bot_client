import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class RiskManagementOptions extends StatefulWidget {
  const RiskManagementOptions({super.key});

  @override
  State<RiskManagementOptions> createState() => _RiskManagementOptionsState();
}

class _RiskManagementOptionsState extends State<RiskManagementOptions> {
  final _margin = TextEditingController();
  final _leverage = TextEditingController();
  final _sLPercentages = TextEditingController();
  final _riskRewardRatio = TextEditingController();
  final _brokerCommission = TextEditingController();
  final _brokerMaximumLeverage = TextEditingController();
  final _commissionPercentage = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;

  void _setFields(Map<String, dynamic>? options) {
    if (options == null || !options.keys.contains('riskManagementOptions')) return;

    setState(() {
      _margin.text = options["riskManagementOptions"]['margin']?.toString() ?? '';
      _leverage.text = options["riskManagementOptions"]['leverage']?.toString() ?? '';
      _sLPercentages.text = options["riskManagementOptions"]['slPercentages']?.toString() ?? '';
      _riskRewardRatio.text = options["riskManagementOptions"]['riskRewardRatio']?.toString() ?? '';
      _brokerCommission.text = options["riskManagementOptions"]['brokerCommission']?.toString() ?? '';
      _brokerMaximumLeverage.text = options["riskManagementOptions"]['brokerMaximumLeverage']?.toString() ?? '';
      _commissionPercentage.text = options["riskManagementOptions"]['commissionPercentage']?.toString() ?? '';
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
      if (_margin.text == '' || _leverage.text == '' || _sLPercentages.text == '' || _riskRewardRatio.text == '' || _brokerCommission.text == '' || _brokerMaximumLeverage.text == '' || _commissionPercentage.text == '') {
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
      data["riskManagementOptions"] = {
        "Margin": double.parse(_margin.text),
        "Leverage": double.parse(_leverage.text),
        "SLPercentages": double.parse(_sLPercentages.text),
        "RiskRewardRatio": double.parse(_riskRewardRatio.text),
        "BrokerCommission": double.parse(_brokerCommission.text),
        "BrokerMaximumLeverage": double.parse(_brokerMaximumLeverage.text),
        "CommissionPercentage": double.parse(_commissionPercentage.text),
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
            controller: _margin,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Margin",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _leverage,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "Leverage",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _sLPercentages,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "SLPercentages",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _riskRewardRatio,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "RiskRewardRatio",
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
              labelText: "BrokerCommission",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _brokerMaximumLeverage,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "BrokerMaximumLeverage",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          TextField(
            controller: _commissionPercentage,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: "CommissionPercentage",
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
