import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _status = Icon(Icons.question_mark);
  bool _loading = false;

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

      String? backendUrl = await AppDataRepository.GetBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      var res = await getClient().get(Uri.parse(backendUrl + 'status/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.BackendAuthKey) ?? ''});

      if (res.statusCode == 200) {
        wasSuccessful = true;
        snackBarMessage = 'Successful';
        setState(() {
          if (res.body != '') _status = Text(jsonDecode(res.body)['status']);
        });
        return;
      }
      snackBarMessage = 'Error';
    } finally {
      setState(() {
        _loading = false;

        if (!wasSuccessful)
          _status = FloatingActionButton(
            onPressed: _getStatus,
            child: Icon(Icons.refresh),
          );

        if (snackBarMessage != '')
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
      });
    }
  }

  void initState() {
    super.initState();
    _getStatus();
  }

  bool _isSubmitting = false;

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

      http.Response res = await getClient().post(Uri.parse(backendUrl + "${action}/"), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.BackendAuthKey) ?? ''});

      Map<String, dynamic>? responseObject = null;
      if (res.body != '') responseObject = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        wasSuccessful = true;
        snackBarMessage = 'Successful';
      } else
        snackBarMessage = responseObject?['message'] ?? 'Error';
    } finally {
      _getStatus();
      setState(() {
        _isSubmitting = false;
        if (wasSuccessful)
          App.showSnackBar(
            snackBarMessage,
            'Close',
            () {},
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var space = SizedBox(
      width: 10,
      height: 35,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Bot"),
        elevation: 3,
        actions: [
          FloatingActionButton(
              onPressed: _getStatus,
              child: Icon(
                Icons.refresh,
              )),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(
                Icons.android,
                size: 48,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            space,
            Center(
              child: Text('Status'),
            ),
            Center(
              child: _loading || _isSubmitting ? CircularProgressIndicator() : _status,
            ),
            space,
            Wrap(
              direction: Axis.horizontal,
              children: [
                ElevatedButton(
                  onPressed: _start,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Start'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: _suspend,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Suspend'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: _stop,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            space,
          ],
        ),
      ),
    );
  }
}
