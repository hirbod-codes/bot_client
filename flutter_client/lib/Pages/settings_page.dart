import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/Options/broker_options.dart';
import 'package:flutter_client/Pages/Options/security_options.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Future<String?> getOptions() async {
    String? backendUrl = await AppDataRepository.GetBackendUrl();
    if (backendUrl == null) return null;

    return (await http.get(Uri.parse(backendUrl + 'options/'))).body;
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _content = BrokerOptions();

  String _title = 'Broker Options';

  var _index = 0;

  bool _refreshing = false;

  void initState() {
    SettingsPage.getOptions().whenComplete(() {
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(_title),
        actions: [
          SizedBox(
            height: 35,
            width: 35,
            child: FloatingActionButton(
              child: _refreshing ? CircularProgressIndicator() : Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _refreshing = true;
                });
                SettingsPage.getOptions().then((value) async {
                  if (value == null) return;

                  (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.Options, value);
                }).whenComplete(() => setState(() {
                      _refreshing = false;
                    }));
              },
            ),
          ),
        ],
      ),
      body: _content,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _index,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onTap: _nav,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.store,
              color: Colors.purple.shade500,
            ),
            label: 'Broker',
            tooltip: 'Broker',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.android,
              color: Colors.purple.shade500,
            ),
            label: 'Bot',
            tooltip: 'Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.radar,
              color: Colors.purple.shade500,
            ),
            label: 'Strategy',
            tooltip: 'Strategy',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calculate,
              color: Colors.purple.shade500,
            ),
            label: 'Indicator',
            tooltip: 'Indicator',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.money,
              color: Colors.purple.shade500,
            ),
            label: 'Risk Management',
            tooltip: 'Risk Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.manage_accounts,
              color: Colors.purple.shade500,
            ),
            label: 'Runner',
            tooltip: 'Runner',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.security,
              color: Colors.purple.shade500,
            ),
            label: 'Security',
            tooltip: 'Security',
          ),
        ],
      ),
    );
  }

  void _nav(int index) {
    switch (index) {
      case 0:
        setState(() {
          _title = 'Broker Options';
          _content = BrokerOptions();
          _index = index;
        });
        break;
      case 1:
        setState(() {
          _title = 'Bot Options';
          _content = BrokerOptions();
          _index = index;
        });
        break;
      case 2:
        setState(() {
          _title = 'Strategy Options';
          _content = BrokerOptions();
          _index = index;
        });
        break;
      case 3:
        setState(() {
          _title = 'Indicator Options';
          _content = BrokerOptions();
          _index = index;
        });
        break;
      case 4:
        setState(() {
          _title = 'Risk Management Options';
          _content = BrokerOptions();
          _index = index;
        });
        break;
      case 5:
        setState(() {
          _title = 'Runner Options';
          _content = BrokerOptions();
          _index = index;
        });
        break;
      case 6:
        setState(() {
          _title = 'Security';
          _content = SecurityOptions();
          _index = index;
        });
        break;
      default:
    }
  }
}
