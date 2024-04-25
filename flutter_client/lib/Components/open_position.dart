import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OpenPosition extends StatefulWidget {
  const OpenPosition({super.key, required List<dynamic> positions, required String symbol, required String timeFrame})
      : _positions = positions,
        _symbol = symbol,
        _timeFrame = timeFrame;

  final String _symbol;
  final String _timeFrame;
  final List<dynamic> _positions;

  @override
  State<OpenPosition> createState() => _OpenPositionState();
}

class _OpenPositionState extends State<OpenPosition> {
  WebSocketChannel? _channel;

  bool _isSubscribed = false;

  double? _price;

  @override
  void initState() {
    super.initState();
    print(widget._positions);
    _initWebSocket();
  }

  void _initWebSocket() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(Uri.parse("wss://open-api-swap.bingx.com/swap-market"));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: _channel == null
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 500,
                child: StreamBuilder(
                  key: widget.key,
                  stream: _channel!.stream,
                  builder: (context, snapshot) {
                    if (!_isSubscribed) {
                      var json = jsonEncode({
                        "id": "1651641469541",
                        "reqType": "sub",
                        "dataType": "${widget._symbol}@kline_${widget._timeFrame}",
                      });
                      Uint8List utf8encode = utf8.encode(json);
                      _channel!.sink.add(utf8encode);

                      _isSubscribed = true;
                    }

                    if (!snapshot.hasData || snapshot.hasError) return const Center(child: CircularProgressIndicator());
                    final decodeGZipJson = gzip.decode(snapshot.data);
                    final rawMessage = utf8.decode(decodeGZipJson);

                    if (rawMessage == "Ping") {
                      _channel!.sink.add("Pong");
                    } else {
                      Map<String, dynamic>? response = jsonDecode(rawMessage) as Map<String, dynamic>?;

                      String? close = response?['data']?[0]['c'];

                      if (close != null) _price = double.parse(close);
                    }

                    return _price == null
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            children: widget._positions.map(
                            (e) {
                              double openedPrice = e['openedPrice'].runtimeType == String ? double.parse(e['openedPrice']) : e['openedPrice'].toDouble();
                              double leverage = e['leverage'].runtimeType == String ? double.parse(e['leverage']) : e['leverage'].toDouble();
                              double margin = e['margin'].runtimeType == String ? double.parse(e['margin']) : e['margin'].toDouble();
                              double unrealizedPnL = (_price! - openedPrice) * leverage * margin / openedPrice;
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background.withOpacity(0.1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        direction: Axis.horizontal,
                                        children: [
                                          RawChip(
                                            elevation: 10,
                                            visualDensity: const VisualDensity(vertical: -4),
                                            label: Text(
                                              e['positionDirection'].toString(),
                                              style: e['positionDirection'].toString().toLowerCase() == 'long'
                                                  ? Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: Colors.green,
                                                      )
                                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: Colors.red,
                                                      ),
                                            ),
                                          ),
                                          RawChip(
                                            elevation: 10,
                                            visualDensity: const VisualDensity(vertical: -4),
                                            label: Text('${e['leverage'].toString()}X'),
                                          ),
                                        ]
                                            .map((e) => Padding(
                                                  padding: EdgeInsets.only(right: 8),
                                                  child: e,
                                                ))
                                            .toList(),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          children: [
                                            const Text('Unrealized PnL'),
                                            Text(
                                              unrealizedPnL.toStringAsFixed(4),
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: unrealizedPnL > 0 ? Colors.green : Colors.red.shade700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          children: [
                                            const Text('Commission'),
                                            Text(e['commission'].toString()),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList());
                  },
                ),
              ),
      );
}
