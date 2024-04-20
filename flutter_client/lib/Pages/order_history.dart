import 'dart:convert';
import 'dart:io';
import 'package:flutter_client/Components/scrollable_table.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Themes/theme.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<dynamic>? _positions;

  bool _refreshing = false;

  String? _symbol;

  @override
  void initState() {
    super.initState();

    getClosedPositions();
  }

  Future<void> getClosedPositions() async {
    String snackBarMessage = 'Successful';

    try {
      setState(() {
        _refreshing = true;
      });

      String? backendUrl = await AppDataRepository.GetBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      var response = await http.get(
        Uri.parse('${backendUrl}closed-positions/'),
        headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''},
      );

      _positions = jsonDecode(response.body) as List<dynamic>;
      if (_positions == null) {
        snackBarMessage = 'Error';
        return;
      }

      _positions = _positions!
          .map((e) => {
                "Symbol": e['symbol'],
                "Profit with commission": e['profitWithCommission'],
                "Commission": e['commission'],
                "Position direction": e['positionDirection'],
                "Opened price": e['openedPrice'],
                "Closed price": e['closedPrice'],
                "Sl price": e['slPrice'],
                "Tp price": e['tpPrice'],
                "Profit": e['profit'],
                "Margin": e['margin'],
                "Leverage": e['leverage'],
                "Created at": e['createdAt'],
                "Closed at": e['closedAt'],
                "Commission ratio": e['commissionRatio'],
                "Position status": e['positionStatus'],
                "Opened at": e['openedAt'],
                "Cancelled at": e['cancelledAt'],
              })
          .toList();
    } finally {
      setState(() {
        _refreshing = false;
        App.showSnackBar(
          snackBarMessage,
          'Close',
          () {},
        );
      });
    }
  }

  final Icon _lightIcon = const Icon(Icons.light_mode_outlined);
  final Icon _darkIcon = const Icon(Icons.dark_mode_outlined);
  Icon _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? const Icon(Icons.light_mode_outlined) : const Icon(Icons.dark_mode_outlined);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Order History"),
          actions: [
            SizedBox(
              height: 70,
              width: 70,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Switch(
                  inactiveTrackColor: Theme.of(context).colorScheme.secondaryContainer,
                  key: ValueKey<Icon>(_themeSwitchIcon),
                  thumbIcon: MaterialStateProperty.all(_themeSwitchIcon),
                  value: customTheme.themeMode == ThemeMode.light,
                  onChanged: (bool value) {
                    customTheme.toggleTheme();
                    setState(() => _themeSwitchIcon = customTheme.themeMode == ThemeMode.light ? _lightIcon : _darkIcon);
                  },
                ),
              ),
            ),
            SizedBox(
              height: 35,
              width: 35,
              child: FloatingActionButton(
                child: _refreshing ? const CircularProgressIndicator() : const Icon(Icons.refresh),
                onPressed: () => getClosedPositions(),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Text(_symbol ?? 'Symbol'),
              SizedBox(
                height: double.maxFinite,
                child: _refreshing
                    ? const CircularProgressIndicator()
                    : (_positions == null || _positions!.isEmpty
                        ? const Text('Empty')
                        : ScrollableTable(
                            buildCell: (BuildContext b, TableVicinity tv) => tv.row == 0
                                ? TableViewCell(
                                    child: Center(
                                      child: Wrap(
                                        children: [
                                          Text(_positions![0].keys.elementAt(tv.column)),
                                        ],
                                      ),
                                    ),
                                  )
                                : TableViewCell(
                                    child: Center(
                                      child: Wrap(
                                        children: [
                                          Text(_positions![tv.row - 1][_positions![0].keys.elementAt(tv.column)].toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                            buildColumnSpan: (index) => const TableSpan(
                              foregroundDecoration: TableSpanDecoration(),
                              extent: FixedTableSpanExtent(100),
                            ),
                            buildRowSpan: (int index) => TableSpan(
                              backgroundDecoration: TableSpanDecoration(
                                color: index.isEven ? Colors.black.withOpacity(0.2) : null,
                              ),
                              extent: const FixedTableSpanExtent(50),
                            ),
                            columnsCount: _positions![0].keys.length,
                            rowsCount: _positions!.length + 1,
                          )),
              ),
            ],
          ),
        ),
      );
}
