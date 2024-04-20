import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/Data/app_data.dart';
import 'package:flutter_client/Pages/Models/candle.dart';
import 'package:flutter_client/Themes/theme.dart';
import 'package:http/http.dart' as http;

class CurrencyChart extends StatefulWidget {
  final List<String> _weekDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final List<String> _monthNames = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];

  CurrencyChart({
    super.key,
    required String fSymbol,
    required String tSymbol,
    required TextStyle lineTooltipItemTextStyle,
    required Color tooltipColor,
    required Color lineColor,
    required Color gradientColor,
    Color? backgroundColor,
  })  : _fSymbol = fSymbol,
        _tSymbol = tSymbol,
        _lineTooltipItemTextStyle = lineTooltipItemTextStyle,
        _tooltipColor = tooltipColor,
        _lineColor = lineColor,
        _backgroundColor = backgroundColor,
        _gradientColor = gradientColor;

  final TextStyle _lineTooltipItemTextStyle;
  final Color _tooltipColor;
  final Color _lineColor;
  final Color? _backgroundColor;
  final Color _gradientColor;
  final String _fSymbol;
  final String _tSymbol;

  @override
  State<CurrencyChart> createState() => _CurrencyChartState();
}

class _CurrencyChartState extends State<CurrencyChart> {
  String _timeFrame = AppStaticData.day;

  List<Candle> _candles = [];

  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;

  Widget _dailyBottomTitles(List<Candle> candles, double value, TitleMeta meta) => Text(widget._weekDays.elementAt(DateTime.fromMillisecondsSinceEpoch(candles.elementAt(value.toInt()).time * 1000).weekday - 1));
  Widget _monthlyBottomTitles(List<Candle> candles, double value, TitleMeta meta) => Text(widget._monthNames.elementAt(DateTime.fromMillisecondsSinceEpoch(candles.elementAt(value.toInt()).time * 1000).month - 1));
  Widget _yearlyBottomTitles(List<Candle> candles, double value, TitleMeta meta) => Text(DateTime.fromMillisecondsSinceEpoch(candles.elementAt(value.toInt()).time * 1000).year.toString());

  @override
  void initState() {
    super.initState();
    _initCandles(_timeFrame).then((value) {
      setState(() {});
    });
  }

  Future _initCandles(String timeFrame) async {
    switch (timeFrame) {
      case AppStaticData.year:
        _candles = await _getYearly();
        break;
      case AppStaticData.month:
        _candles = await _getMonthly();
        break;
      case AppStaticData.day:
        _candles = await _getDaily();
        break;
      default:
    }

    _minX = 0;
    _maxX = _candles.length.toDouble() - 1;
    _minY = _candles.reduce((value, elm) => elm.close < value.close ? elm : value).close.toDouble() - 0.5;
    _maxY = _candles.reduce((value, elm) => elm.close > value.close ? elm : value).close.toDouble() + 0.5;
  }

  Future<dynamic> _getDaily() async {
    http.Response dailyResponse = await http.get(Uri.parse("https://min-api.cryptocompare.com/data/v2/histoday?fsym=${widget._fSymbol}&tsym=${widget._tSymbol}&limit=7&aggregate=1&aggregatePredictableTimePeriods=true&allData=false&api_key=505ac52e6d5e0a3cd9ed796bcac4f3c11e5e84967eb8511080603f40ed2062a3"));

    var daily = jsonDecode(dailyResponse.body) as Map<String, dynamic>;
    return (daily['Data']['Data'] as List<dynamic>).asMap().entries.map<Candle>((e) => Candle(e.value['close'].toDouble(), e.value['open'].toDouble(), e.value['low'].toDouble(), e.value['high'].toDouble(), e.value['time'].toInt())).toList();
  }

  Future<dynamic> _getMonthly() async {
    http.Response monthlyResponse = await http.get(Uri.parse("https://min-api.cryptocompare.com/data/v2/histoday?fsym=${widget._fSymbol}&tsym=${widget._tSymbol}&limit=360&aggregate=1&aggregatePredictableTimePeriods=true&allData=false&api_key=505ac52e6d5e0a3cd9ed796bcac4f3c11e5e84967eb8511080603f40ed2062a3"));

    var monthly = jsonDecode(monthlyResponse.body) as Map<String, dynamic>;
    return (monthly['Data']['Data'] as List<dynamic>).asMap().entries.map<Candle>((e) => Candle(e.value['close'].toDouble(), e.value['open'].toDouble(), e.value['low'].toDouble(), e.value['high'].toDouble(), e.value['time'].toInt())).toList();
  }

  Future<dynamic> _getYearly() async {
    http.Response yearlyResponse = await http.get(Uri.parse("https://min-api.cryptocompare.com/data/v2/histoday?fsym=${widget._fSymbol}&tsym=${widget._tSymbol}&aggregate=1&aggregatePredictableTimePeriods=true&allData=true&api_key=505ac52e6d5e0a3cd9ed796bcac4f3c11e5e84967eb8511080603f40ed2062a3"));

    var yearly = jsonDecode(yearlyResponse.body) as Map<String, dynamic>;
    return (yearly['Data']['Data'] as List<dynamic>).asMap().entries.map<Candle>((e) => Candle(e.value['close'].toDouble(), e.value['open'].toDouble(), e.value['low'].toDouble(), e.value['high'].toDouble(), e.value['time'].toInt())).toList();
  }

  void _changeTimeFrame(String s) {
    setState(() {
      _candles = [];
    });
    _initCandles(s).then((value) {
      setState(() {
        _timeFrame = s;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: _candles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LineChart(
                  LineChartData(
                    backgroundColor: widget._backgroundColor,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: (value > _minY + ((_maxY - _minY) * 0.05) && value < _maxY - ((_maxY - _minY) * 0.05)) ? Text(value > 1000 ? '${(value / 1000.0).toStringAsFixed(1)}K' : value.toStringAsFixed(1)) : const Text(""),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _timeFrame != AppStaticData.year ? (_maxX - _minX) / 7 : (_maxX - _minX) / 4,
                          getTitlesWidget: (value, meta) {
                            Widget child = const Text('');
                            switch (_timeFrame) {
                              case AppStaticData.year:
                                child = _yearlyBottomTitles(_candles, value, meta);
                                break;
                              case AppStaticData.month:
                                child = _monthlyBottomTitles(_candles, value, meta);
                                break;
                              case AppStaticData.day:
                                child = _dailyBottomTitles(_candles, value, meta);
                                break;
                              default:
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: (value != 0) ? child : const Text(""),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        curveSmoothness: 0.2,
                        color: widget._lineColor,
                        barWidth: 1.5,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              customTheme.themeMode == ThemeMode.light ? widget._gradientColor.withOpacity(0.6) : widget._gradientColor.withOpacity(0.3),
                              widget._gradientColor.withOpacity(0),
                            ],
                          ),
                        ),
                        spots: _candles.asMap().entries.map<FlSpot>((e) => FlSpot(e.key.toDouble(), e.value.close)).toList(),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchSpotThreshold: 30,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipPadding: const EdgeInsets.only(left: 15, top: 0, bottom: 0, right: 0),
                        tooltipMargin: 0,
                        tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                        getTooltipColor: (touchedSpot) => widget._tooltipColor,
                        maxContentWidth: 250,
                        getTooltipItems: (touchedSpots) => touchedSpots
                            .asMap()
                            .entries
                            .map<LineTooltipItem>(
                              (e) => LineTooltipItem(
                                "\$${e.value.y}",
                                widget._lineTooltipItemTextStyle,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    minX: _minX,
                    maxX: _maxX,
                    minY: _minY,
                    maxY: _maxY,
                  ),
                ),
        ),
        const SizedBox(
          height: 20,
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => constraints.maxWidth > 320
              ? SegmentedButton(
                  segments: const [
                    ButtonSegment(enabled: true, value: AppStaticData.day, label: Text('Daily')),
                    ButtonSegment(enabled: true, value: AppStaticData.month, label: Text('Monthly')),
                    ButtonSegment(enabled: true, value: AppStaticData.year, label: Text('Yearly')),
                  ],
                  selected: <String>{_timeFrame},
                  onSelectionChanged: (s) => _changeTimeFrame(s.first),
                )
              : Center(
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: [
                      const SizedBox(
                        width: 2,
                      ),
                      FilledButton(
                        onPressed: () => _changeTimeFrame(AppStaticData.day),
                        child: const Text("Daily"),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      FilledButton(
                        onPressed: () => _changeTimeFrame(AppStaticData.month),
                        child: const Text("Monthly"),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      FilledButton(
                        onPressed: () => _changeTimeFrame(AppStaticData.year),
                        child: const Text("Yearly"),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
