import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class RiskManagementOptions extends StatefulWidget {
  const RiskManagementOptions({super.key});

  @override
  State<RiskManagementOptions> createState() => _RiskManagementOptionsState();
}

class _RiskManagementOptionsState extends State<RiskManagementOptions> {
  var _margin = TextEditingController();
  var _leverage = TextEditingController();
  var _sLPercentages = TextEditingController();
  var _riskRewardRatio = TextEditingController();
  var _brokerCommission = TextEditingController();
  var _brokerMaximumLeverage = TextEditingController();
  var _commissionPercentage = TextEditingController();

  void _setFields(Map<String, dynamic>? options) {
    if (options == null) return;

    setState(() {
      _margin.text = options['_margin']?.toString() ?? '';
      _leverage.text = options['_leverage']?.toString() ?? '';
      _sLPercentages.text = options['_sLPercentages']?.toString() ?? '';
      _riskRewardRatio.text = options['_riskRewardRatio']?.toString() ?? '';
      _brokerCommission.text = options['_brokerCommission']?.toString() ?? '';
      _brokerMaximumLeverage.text = options['_brokerMaximumLeverage']?.toString() ?? '';
      _commissionPercentage.text = options['_commissionPercentage']?.toString() ?? '';
    });
  }

  void initState() {
    SettingsPage.getOptions().then((options) {
      if (options == null) return;

      AppStaticData.getSharedPreferences().then((value) {
        _setFields((jsonDecode(options) as Map<String, dynamic>)['riskManagementOptions']);
      }).whenComplete(() {
        super.initState();
      });
    });
  }

  bool _isSubmitting = false;

  void _submit() async {
    if (_margin.text == '' || _leverage.text == '' || _sLPercentages.text == '' || _riskRewardRatio.text == '' || _brokerCommission.text == '' || _brokerMaximumLeverage.text == '' || _commissionPercentage.text == '') {
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

    var data = {"Margin": double.parse(_margin.text), "Leverage": double.parse(_leverage.text), "SLPercentages": double.parse(_sLPercentages.text), "RiskRewardRatio": double.parse(_riskRewardRatio.text), "BrokerCommission": double.parse(_brokerCommission.text), "BrokerMaximumLeverage": double.parse(_brokerMaximumLeverage.text), "CommissionPercentage": double.parse(_commissionPercentage.text)};

    http.Response res = await http.patch(Uri.parse(backendUrl + 'risk-management-options/'), body: jsonEncode(data), headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});

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
            controller: _margin,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Margin",
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
            controller: _leverage,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Leverage",
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
            controller: _sLPercentages,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "SLPercentages",
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
            controller: _riskRewardRatio,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "RiskRewardRatio",
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
              labelText: "BrokerCommission",
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
            controller: _brokerMaximumLeverage,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "BrokerMaximumLeverage",
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
            controller: _commissionPercentage,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "CommissionPercentage",
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
