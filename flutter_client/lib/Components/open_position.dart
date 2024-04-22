import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OpenPosition extends StatefulWidget {
  const OpenPosition({super.key});

  @override
  State<OpenPosition> createState() => _OpenPositionState();
}

class _OpenPositionState extends State<OpenPosition> {
  String? _listenKey;

  WebSocketChannel? _channel;
  final List<String> _websocketEventsWidget = [''];
  Widget _websocketReasonWidget = const Text('_websocketreasonWidget');
  Widget _websocketErrorWidget = const Text('_websocketErrorWidget');
  Widget _websocketAccountConfigWidget = const Text('_websocketAccountConfigWidget');
  Widget _websocketAccountWidget = const Text('_websocketAccountWidget');
  int _pingCount = 0;

  final bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    getListenKey().then((value) {
      initWebSocket();
    });
  }

  Future getListenKey() async {
    String snackBarMessage = '';
    try {
      SharedPreferences sharedPreferences = await AppStaticData.getSharedPreferences();

      _listenKey = sharedPreferences.getString(AppDataKeys.listenKey);

      if (!_isExpired && _listenKey != null) {
        snackBarMessage = "listen key already fetched.";
        return;
      }

      String? optionsJson = sharedPreferences.getString(AppDataKeys.options);
      if (optionsJson?.isEmpty ?? true) {
        snackBarMessage = 'Options are not available.';
        return;
      }

      String? apiKey = (jsonDecode(optionsJson!) as Map<String, dynamic>)['brokerOptions']?['apiKey'];

      if (apiKey?.isEmpty ?? true) {
        snackBarMessage = 'Options are not available.';
        return;
      }

      http.Response res = await http.post(
        Uri.parse("https://open-api.bingx.com/openApi/user/auth/userDataStream"),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.primaryType,
          "X-BX-APIKEY": apiKey!,
        },
      );
      _listenKey = (jsonDecode(res.body) as Map<String, dynamic>)['listenKey'];
      bool result = await sharedPreferences.setString(AppDataKeys.listenKey, _listenKey!);
      if (result) snackBarMessage = "listen key fetched.";
    } finally {
      setState(() {
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

  void initWebSocket() {
    if (_listenKey == null) return;

    _channel = WebSocketChannel.connect(Uri.parse("wss://open-api-swap.bingx.com/swap-market?listenKey=$_listenKey"));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: _channel == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder(
                key: widget.key,
                stream: _channel!.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (_listenKey == null) {
                      getListenKey().then((value) => initWebSocket());
                    } else {
                      initState();
                    }

                    return const Center(child: CircularProgressIndicator());
                  }

                  try {
                    if (!snapshot.hasData || snapshot.hasError) return const Center(child: CircularProgressIndicator());
                    final decodeGZipJson = gzip.decode(snapshot.data);
                    final rawMessage = utf8.decode(decodeGZipJson);

                    if (rawMessage == "Ping") {
                      _channel!.sink.add("Pong");
                      _pingCount++;
                    } else {
                      Map<String, dynamic> response = jsonDecode(rawMessage) as Map<String, dynamic>;

                      _websocketReasonWidget = Text(response['m'] ?? "null");
                      _websocketEventsWidget.add(response['e'] ?? "null");

                      if (response['e'] == 'listenKeyExpired') {
                        getListenKey().then((value) => initWebSocket());
                        return const Text('Expired');
                      }

                      if (response['e'] == 'ACCOUNT_CONFIG_UPDATE') {
                        _websocketAccountConfigWidget = Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(response['ac']?['s']?.toString() ?? "null"),
                            Text(response['ac']?['l']?.toString() ?? "null"),
                            Text(response['ac']?['S']?.toString() ?? "null"),
                            Text(response['ac']?['mt']?.toString() ?? "null"),
                          ],
                        );
                      }

                      if (response['e'] == 'ACCOUNT_UPDATE') {
                        _websocketAccountWidget = Column(
                          children: [
                            Text(response['a']?['P']?[0]?['up']?.toString() ?? "null"),
                          ],
                        );
                      }
                    }
                  } catch (e) {
                    _websocketErrorWidget = Text(e.toString());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_pingCount.toString()),
                      _websocketErrorWidget,
                      _websocketReasonWidget,
                      ..._websocketEventsWidget.map((e) => Text(e)),
                      _websocketAccountConfigWidget,
                      _websocketAccountWidget,
                    ],
                  );
                },
              ),
      );
}
