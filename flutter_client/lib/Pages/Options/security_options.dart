import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';

class SecurityOptions extends StatefulWidget {
  const SecurityOptions({super.key});

  @override
  State<SecurityOptions> createState() => SecurityOptionsState();
}

class SecurityOptionsState extends State<SecurityOptions> {
  final _domain = TextEditingController();
  final _port = TextEditingController();
  final _apiKey = TextEditingController();

  @override
  void initState() {
    initAsync().then((value) {
      super.initState();
    });
  }

  Future<void> initAsync() async {
    _domain.text = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.backendDomain) ?? '';
    _port.text = (await AppStaticData.getSharedPreferences()).getInt(AppDataKeys.backendPort)?.toString() ?? '';
    _apiKey.text = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.backendAuthKey) ?? '';
  }

  Future<void> _submit() async {
    String snackBarMessage = 'Error';

    try {
      bool? backendDomainResult = await (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.backendDomain, _domain.text);
      bool? backendPortResult = await (await AppStaticData.getSharedPreferences()).setInt(AppDataKeys.backendPort, int.parse(_port.text));
      bool? backendAuthKeyResult = await (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.backendAuthKey, _apiKey.text);

      if (backendDomainResult != true || backendPortResult != true || backendAuthKeyResult != true) {
        snackBarMessage = 'failed to store input.';
        return;
      }

      String? options = await SettingsPage.getOptions();
      if (options == null) {
        snackBarMessage = 'failed to fetch options.';
        return;
      }

      bool result = await (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.options, options);

      if (result == true) snackBarMessage = 'Successful';
    } finally {
      App.showSnackBar(
        snackBarMessage,
        'Close',
        () {},
      );
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
            controller: _domain,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: "Domain",
              hintText: "example.com or an IP address",
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
            controller: _port,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Port",
              hintText: "443",
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
            controller: _apiKey,
            decoration: const InputDecoration(
              labelText: "Api Authentication Key",
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
          ElevatedButton(onPressed: _submit, child: const Text('Update')),
        ],
      ),
    );
  }
}
