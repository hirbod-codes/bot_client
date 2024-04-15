import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/Charts/line_chart.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget Function(dynamic context) _status = (context) => const Icon(Icons.question_mark_outlined, size: 50);

  bool _loading = false;

  bool _isSubmitting = false;

  String _selectedStatus = "";

  void _start() => _submit('start');

  void _suspend() => _submit('suspend');

  void _stop() => _submit('stop');

  void _getStatus() async {
    if (_loading) return;

    bool wasSuccessful = false;
    String snackBarMessage = '';
    try {
      setState(() {
        _loading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      String? backendUrl = await AppDataRepository.GetBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      var res = await http.get(Uri.parse('${backendUrl}status/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      if (res.statusCode == 200) {
        wasSuccessful = true;
        snackBarMessage = 'Successful';
        setState(() {
          if (res.body != '') _status = (context) => Text(jsonDecode(res.body)['status'], style: Theme.of(context).textTheme.titleLarge);
          switch (jsonDecode(res.body)['status']) {
            case 'RUNNING':
              _selectedStatus = 'start';
              break;
            case 'SUSPENDED':
              _selectedStatus = 'suspend';
              break;
            case 'STOPPED':
              _selectedStatus = 'stop';
              break;
            default:
          }
        });
        return;
      }
      snackBarMessage = 'Error';
    } finally {
      setState(() {
        _loading = false;

        if (!wasSuccessful) {
          _status = (context) => SizedBox(
                width: 35,
                height: 35,
                child: FloatingActionButton(
                  onPressed: _getStatus,
                  child: const Icon(Icons.refresh_outlined),
                ),
              );
        }

        if (snackBarMessage != '') {
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getStatus();
  }

  void _submit(String action) async {
    if (_isSubmitting) return;

    bool wasSuccessful = false;
    String snackBarMessage = 'Error';
    try {
      setState(() {
        _isSubmitting = true;
      });

      String? backendUrl = await AppDataRepository.GetBackendUrl();
      if (backendUrl == null || !['start', 'suspend', 'stop'].contains(action)) {
        snackBarMessage = 'No URL provided.';
        return;
      }

      http.Response res = await http.post(Uri.parse("$backendUrl$action/"), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      Map<String, dynamic>? responseObject;
      if (res.body != '') responseObject = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        wasSuccessful = true;
        snackBarMessage = 'Successful';
      } else {
        snackBarMessage = responseObject?['message'] ?? 'Error';
      }
    } finally {
      _getStatus();
      setState(() {
        _isSubmitting = false;
        if (wasSuccessful) {
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          SizedBox(
            height: 35,
            width: 35,
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.refresh_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Text('Status', style: Theme.of(context).textTheme.copyWith(bodyMedium: const TextStyle(color: Colors.grey)).bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: (_loading || _isSubmitting) ? const CircularProgressIndicator() : _status(context),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: SegmentedButton(
                  showSelectedIcon: false,
                  emptySelectionAllowed: true,
                  segments: const [
                    ButtonSegment(enabled: true, value: 'start', label: Text('Start'), icon: Icon(Icons.play_arrow_outlined)),
                    ButtonSegment(enabled: true, value: 'suspend', label: Text('Suspend'), icon: Icon(Icons.pause_outlined)),
                    ButtonSegment(enabled: true, value: 'stop', label: Text('Stop'), icon: Icon(Icons.stop_outlined)),
                  ],
                  selected: <String>{_selectedStatus},
                  onSelectionChanged: (s) {
                    switch (s.first) {
                      case 'start':
                        _start();
                        break;
                      case 'suspend':
                        _suspend();
                        break;
                      case 'stop':
                        _stop();
                        break;
                      default:
                    }
                    setState(() {
                      _selectedStatus = s.first;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 90,
              ),
              CurrencyChart(
                fSymbol: 'BTC',
                tSymbol: 'USDT',
                lineColor: Colors.yellow.shade700,
                gradientColor: Colors.yellow,
                tooltipColor: Theme.of(context).colorScheme.secondary,
                lineTooltipItemTextStyle: Theme.of(context).textTheme.bodySmall!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
