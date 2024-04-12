import 'package:flutter/material.dart';
import 'package:flutter_client/Data/AppData.dart';
import 'package:flutter_client/Pages/settings_page.dart';
import 'package:flutter_client/main.dart';

class SecurityOptions extends StatefulWidget {
  const SecurityOptions({super.key});

  @override
  State<SecurityOptions> createState() => SecurityOptionsState();
}

class SecurityOptionsState extends State<SecurityOptions> {
  var _domain = TextEditingController();
  var _port = TextEditingController();
  var _apiKey = TextEditingController();

  void initState() {
    initAsync().then((value) {
      super.initState();
    });
  }

  Future<void> initAsync() async {
    _domain.text = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.BackendDomain) ?? '';
    _port.text = (await AppStaticData.getSharedPreferences()).getInt(AppDataKeys.BackendPort)?.toString() ?? '';
    _apiKey.text = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.BackendAuthKey) ?? '';
  }

  Future<void> _submit() async {
    String snackBarMessage = 'Error';

    try {
      bool? BackendDomainResult = await (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.BackendDomain, _domain.text);
      bool? BackendPortResult = await (await AppStaticData.getSharedPreferences()).setInt(AppDataKeys.BackendPort, int.parse(_port.text));
      bool? BackendAuthKeyResult = await (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.BackendAuthKey, _apiKey.text);

      if (BackendDomainResult != true || BackendPortResult != true || BackendAuthKeyResult != true) {
        snackBarMessage = 'failed to store input.';
        return;
      }

      String? options = await SettingsPage.getOptions();
      if (options == null) {
        snackBarMessage = 'failed to fetch options.';
        return;
      }

      bool result = await (await AppStaticData.getSharedPreferences()).setString(AppDataKeys.Options, options);

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
    var space = SizedBox(
      width: 10,
      height: 35,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextField(
              controller: _domain,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
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
              decoration: InputDecoration(
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
              decoration: InputDecoration(
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
            SizedBox(
              height: 70,
              width: 10,
            ),
            ElevatedButton(onPressed: _submit, child: Text('Update')),
          ],
        ),
      ),
    );
  }
}
