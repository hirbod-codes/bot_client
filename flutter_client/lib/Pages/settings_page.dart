import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _content = Text('');

  String _title = '';

  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(_title),
      ),
      body: _content,
      bottomNavigationBar: BottomNavigationBar(
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
            label: 'Bot Runner',
            tooltip: 'Bot Runner',
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
      default:
    }
  }
}

class BrokerOptions extends StatefulWidget {
  const BrokerOptions({super.key});

  @override
  State<BrokerOptions> createState() => _BrokerOptionsState();
}

class _BrokerOptionsState extends State<BrokerOptions> {
  var _timeFrameDefualt = TextEditingValue(text: "");
  var _tiemFrame = null;

  var _symbol = TextEditingController();
  var _commission = TextEditingController();
  var _baseUrl = TextEditingController();

  bool _isSubmitting = false;

  var _apiKey;

  var _apiSecret;

  void initState() {
    super.initState();

    // _symbol.text = "bbbbbb";
  }

  @override
  Widget build(BuildContext context) {
    var space = SizedBox(
      width: 10,
      height: 35,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Center(
            child: Text('Broker Options'),
          ),
          Divider(),
          space,
          TextField(
            controller: _symbol,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Symbol",
              hintText: "BTC-USDT",
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
            controller: _commission,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "Commission",
              hintText: "0.001",
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
            controller: _baseUrl,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "Base Url",
              hintText: "open-api-vst.bingx.com",
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
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "API Key",
              hintText: "open-api-vst.bingx.com",
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
            controller: _apiSecret,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: "API Secret",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          space,
          Autocomplete<String>(
            initialValue: _timeFrameDefualt,
            optionsBuilder: (TextEditingValue textEditingValue) =>
                timeFrames.keys.where((timeFrame) => timeFrame
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase())),
            onSelected: (String selection) => _tiemFrame = selection,
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) =>
                    TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onEditingComplete: onFieldSubmitted,
              decoration: InputDecoration(
                labelText: "Time Frame",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 70,
            width: 10,
          ),
          ElevatedButton(onPressed: _submit, child: Text('Update')),
        ],
      ),
    );
  }

  void _submit() {}
}

var timeFrames = {
  "1m": 60,
  "3m": 3 * 60,
  "5m": 5 * 60,
  "15m": 15 * 60,
  "30m": 30 * 60,
  "1h": 60 * 60,
  "4h": 4 * 60 * 60,
  "1D": 24 * 60 * 60,
  "1W": 7 * 24 * 60 * 60,
  "1M": 30 * 24 * 60 * 60,
};
