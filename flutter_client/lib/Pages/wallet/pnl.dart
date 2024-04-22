import 'dart:convert';
import 'dart:io';

import 'package:flutter_client/Components/scrollable_table.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class Pnl extends StatefulWidget {
  const Pnl({super.key});

  @override
  State<Pnl> createState() => _PnlState();
}

class _PnlState extends State<Pnl> {
  bool _isLoading = false;
  Map<String, List<dynamic>>? _pnls;

  @override
  void initState() {
    super.initState();
    _getPnl();
  }

  Future<void> _getPnl() async {
    String snackBarMessage = 'Error';

    try {
      setState(() => _isLoading = true);

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      http.Response res = await http.get(Uri.parse('${backendUrl}pnl/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      for (var e in (jsonDecode(res.body) as List<dynamic>)) {
        _pnls ??= {};
        _pnls![e['symbol']] ??= [];

        _pnls![e['symbol']]!.add({
          "time": e['time'],
          "income": e['income'],
          "info": e['info'],
          "incomeType": e['incomeType'],
          "asset": e['asset'],
        });
      }

      if (_pnls != null) snackBarMessage = 'Successful';
    } finally {
      setState(() {
        _isLoading = false;

        App.showSnackBar(
          snackBarMessage,
          'Close',
          () {},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => _isLoading
      ? const Center(child: CircularProgressIndicator())
      : (_pnls == null || _pnls!.isEmpty)
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
              length: _pnls!.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: _pnls!.keys.map((e) => Text(e)).toList(),
                  ),
                  SizedBox(
                    height: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                      child: TabBarView(
                        children: _pnls!.entries
                            .map(
                              (pnl) => ScrollableTable(
                                buildCell: (BuildContext b, TableVicinity tv) => tv.row == 0
                                    ? TableViewCell(
                                        child: Center(
                                          child: Wrap(
                                            children: [
                                              Text(pnl.value[0].keys.elementAt(tv.column)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : TableViewCell(
                                        child: Center(
                                          child: Wrap(
                                            children: [
                                              Text(pnl.value[tv.row - 1][pnl.value[0].keys.elementAt(tv.column)].toString()),
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
                                  extent: const FixedTableSpanExtent(50),
                                ),
                                columnsCount: pnl.value[0].keys.length,
                                rowsCount: pnl.value.length + 1,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
}
