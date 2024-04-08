import 'dart:convert';

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
  Widget _status = Text('?');
  bool _loading = true;

  void _start() => _submit('start');

  void _suspend() => _submit('suspend');

  void _stop() => _submit('stop');

  void _getStatus() {
    setState(() {
      _loading = true;
    });

    AppDataRepository.GetBackendUrl().then((backendUrl) {
      if (backendUrl == null) {
        App.showSnackBar(
          'No URL provided',
          'Close',
          () {},
        );
        return;
      }

      http.get(Uri.parse(backendUrl + 'status/')).then((res) {
        if (res.statusCode == 200)
          setState(() {
            _status = res.body != '' ? Text(jsonDecode(res.body)['status']) : Text('?');
          });
        else {
          _status = FloatingActionButton(
            onPressed: _getStatus,
            child: Icon(Icons.refresh),
          );
          App.showSnackBar(
            jsonDecode(res.body)['message'] ?? 'Error',
            'Close',
            () {},
          );
        }
      }).whenComplete(() {
        setState(() {
          _loading = false;
        });
      });
    });
  }

  void initState() {
    super.initState();
    _getStatus();
  }

  bool _isSubmitting = false;

  void _submit(String action) async {
    if (_isSubmitting) return;

    String? backendUrl = await AppDataRepository.GetBackendUrl();
    if (backendUrl == null || !['start', 'suspend', 'stop'].contains(action)) {
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

    http.Response res = await http.post(Uri.parse(backendUrl + "${action}/"));

    Map<String, dynamic>? responseObject = null;
    if (res.body != '') responseObject = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 200) {
      _getStatus();
      App.showSnackBar(
        'Successful',
        'Close',
        () {},
      );
    } else {
      _getStatus();
      App.showSnackBar(
        responseObject?['message'] ?? 'Error',
        'Close',
        () {},
      );
    }

    setState(() {
      _isSubmitting = false;
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _start,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Start'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                    backgroundColor: Colors.blue, // <-- Button color
                    foregroundColor: Colors.white, // <-- Splash color
                  ),
                ),
                ElevatedButton(
                  onPressed: _suspend,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Suspend'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                    backgroundColor: Colors.yellow, // <-- Button color
                    foregroundColor: Colors.black, // <-- Splash color
                  ),
                ),
                ElevatedButton(
                  onPressed: _stop,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                    backgroundColor: Colors.red, // <-- Button color
                    foregroundColor: Colors.black, // <-- Splash color
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
