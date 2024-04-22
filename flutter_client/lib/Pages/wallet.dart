import 'dart:convert';
import 'dart:io';

import 'package:flutter_client/Components/scrollable_table.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Themes/theme.dart';
import 'package:flutter_client/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool _isAssetLoading = false;
  bool _isPnlLoading = false;
  double? _equity;
  double? _availableMargin;
  double? _usedMargin;
  List<dynamic>? _pnls;

  @override
  void initState() {
    super.initState();
    _getAssets();
    _getPnl();
  }

  Future<void> _getAssets() async {
    String snackBarMessage = 'Error';

    try {
      setState(() => _isAssetLoading = true);

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      http.Response res = await http.get(Uri.parse('${backendUrl}assets/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      Map<String, dynamic>? assets = jsonDecode(res.body) as Map<String, dynamic>?;

      _equity = assets?['equity'] as double?;
      _availableMargin = assets?['availableMargin'] as double?;
      _usedMargin = assets?['usedMargin'] as double?;

      if (_equity != null && _availableMargin != null && _usedMargin != null) snackBarMessage = 'Successful';
    } finally {
      setState(() {
        _isAssetLoading = false;

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

  Future<void> _getPnl() async {
    String snackBarMessage = 'Error';

    try {
      setState(() => _isPnlLoading = true);

      String? backendUrl = await AppDataRepository.getBackendUrl();
      if (backendUrl == null) {
        snackBarMessage = 'No URL provided!';
        return;
      }

      http.Response res = await http.get(Uri.parse('${backendUrl}pnl/'), headers: {HttpHeaders.authorizationHeader: AppStaticData.sharedPreferences?.getString(AppDataKeys.backendAuthKey) ?? ''});

      _pnls = jsonDecode(res.body) as List<dynamic>;

      if (_pnls != null) snackBarMessage = 'Successful';
    } finally {
      setState(() {
        _isPnlLoading = false;

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
          title: const Text("Wallet"),
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
                child: _isAssetLoading ? const CircularProgressIndicator() : const Icon(Icons.refresh),
                onPressed: () {
                  _getAssets();
                  _getPnl();
                },
              ),
            ),
          ],
        ),
        body: _isAssetLoading
            ? const Center(child: CircularProgressIndicator())
            : (_equity == null || _availableMargin == null || _usedMargin == null
                ? Center(
                    child: Wrap(
                      children: [
                        const Icon(Icons.dangerous_outlined),
                        const Text('System failed to fetch assets.'),
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        ...[
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              const Text('Balance:'),
                              Text(_equity?.toStringAsFixed(4) ?? 'NAN'),
                            ],
                          ),
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              const Text('Available Margin:'),
                              Text(_availableMargin?.toStringAsFixed(4) ?? 'NAN'),
                            ],
                          ),
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              const Text('Used Margin:'),
                              Text(_usedMargin?.toStringAsFixed(4) ?? 'NAN'),
                            ],
                          ),
                        ].map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: e,
                            ),
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          height: double.maxFinite,
                          child: _isPnlLoading
                              ? const Center(child: CircularProgressIndicator())
                              : (_pnls == null || _pnls!.isEmpty
                                  ? const Center(child: CircularProgressIndicator())
                                  : ScrollableTable(
                                      buildCell: (BuildContext b, TableVicinity tv) => tv.row == 0
                                          ? TableViewCell(
                                              child: Center(
                                                child: Wrap(
                                                  children: [
                                                    Text(_pnls![0].keys.elementAt(tv.column)),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : TableViewCell(
                                              child: Center(
                                                child: Wrap(
                                                  children: [
                                                    Text(_pnls![tv.row - 1][_pnls![0].keys.elementAt(tv.column)].toString()),
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
                                      columnsCount: _pnls![0].keys.length,
                                      rowsCount: _pnls!.length + 1,
                                    )),
                        ),
                      ],
                    ),
                  )),
      );
}
