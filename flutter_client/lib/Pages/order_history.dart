import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
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
  Map<String, List<dynamic>>? _positions;

  bool _refreshing = false;

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

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      var response = await http.get(
        Uri.parse('${backendUrl}closed-positions/'),
        headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''},
      );

      var positions = jsonDecode(response.body) as List<dynamic>?;
      if (positions == null) {
        snackBarMessage = 'Error';
        return;
      }

      for (var position in positions) {
        _positions ??= {};
        _positions![position['symbol']] ??= [];

        _positions![position['symbol']]!.add({
          "_": [position['openedAt'].replaceAll(RegExp("T"), " "), position['positionDirection'], '${position['leverage']}X'],
          "Profit with commission": position['profitWithCommission'],
          "Commission": position['commission'],
          "Opened price": position['openedPrice'],
          "Closed price": position['closedPrice'],
          "Sl price": position['slPrice'],
          "Tp price": position['tpPrice'],
          "Profit": position['profit'],
          "Margin": position['margin'],
          "Created at": position['createdAt'],
          "Closed at": position['closedAt'],
          "Commission ratio": position['commissionRatio'],
          "Position status": position['positionStatus'],
          "Position direction": position['positionDirection'],
          "Leverage": position['leverage'],
          "Opened at": position['openedAt'],
          "Cancelled at": position['cancelledAt'],
        });
      }
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
        body: _refreshing
            ? const Center(child: CircularProgressIndicator())
            : ((_positions == null || (_positions?.isEmpty ?? true))
                ? Center(
                    child: Wrap(
                      children: [
                        const Icon(Icons.dangerous_outlined),
                        const Text('System failed to fetch orders.'),
                      ]
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: e,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : DefaultTabController(
                    length: _positions!.length,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          tabs: _positions!.keys.map((e) => Text(e)).toList(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: TabBarView(
                              children: _positions!.entries
                                  .map(
                                    (p) => ScrollableTable(
                                      buildCell: (BuildContext b, TableVicinity tv) => tv.row == 0
                                          ? TableViewCell(
                                              child: Center(
                                                child: Wrap(
                                                  children: [
                                                    tv.column == 0 ? const Text('') : Text(p.value[0].keys.elementAt(tv.column)),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : tv.column == 0
                                              ? TableViewCell(
                                                  child: Center(
                                                    child: Wrap(
                                                      direction: Axis.vertical,
                                                      crossAxisAlignment: WrapCrossAlignment.center,
                                                      children: (p.value[tv.row - 1][p.value[0].keys.elementAt(0)] as List<dynamic>)
                                                          .asMap()
                                                          .entries
                                                          .map(
                                                            (s) => s.key == 1
                                                                ? Text(
                                                                    s.value.toString(),
                                                                    style: s.value.toString().toLowerCase() == 'long' ? Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.green) : Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red),
                                                                  )
                                                                : Text(s.value.toString()),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ),
                                                )
                                              : tv.column == 1
                                                  ? TableViewCell(
                                                      child: Center(
                                                        child: Wrap(
                                                          children: [
                                                            p.value[tv.row - 1][p.value[0].keys.elementAt(tv.column)] > 0
                                                                ? Text(
                                                                    p.value[tv.row - 1][p.value[0].keys.elementAt(tv.column)]?.toString() ?? '-',
                                                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.green),
                                                                  )
                                                                : Text(
                                                                    p.value[tv.row - 1][p.value[0].keys.elementAt(tv.column)]?.toString() ?? '-',
                                                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red.shade700),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : TableViewCell(
                                                      child: Center(
                                                        child: Wrap(
                                                          children: [
                                                            Text(p.value[tv.row - 1][p.value[0].keys.elementAt(tv.column)]?.toString() ?? '-'),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                      buildColumnSpan: (index) => const TableSpan(
                                        foregroundDecoration: TableSpanDecoration(),
                                        extent: FixedTableSpanExtent(150),
                                      ),
                                      buildRowSpan: (int index) => TableSpan(
                                        backgroundDecoration: TableSpanDecoration(
                                          color: index.isEven ? Colors.black.withOpacity(0.2) : null,
                                        ),
                                        extent: const FixedTableSpanExtent(70),
                                      ),
                                      columnsCount: p.value[0].keys.length,
                                      rowsCount: p.value.length + 1,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
      );
}
