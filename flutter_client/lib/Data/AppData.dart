import 'package:shared_preferences/shared_preferences.dart';

class AppDataKeys {
  static String BackendDomain = 'BackendDomain';
  static String BackendPort = 'BackendPort';
  static String BackendAuthKey = 'BackendAuthKey';
  static String Options = 'Options';
}

class AppDataRepository {
  static Future<String?> GetBackendUrl() async {
    String? domain = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.BackendDomain);
    int? port = (await AppStaticData.getSharedPreferences()).getInt(AppDataKeys.BackendPort);
    String? authKey = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.BackendAuthKey);

    if (domain == null || port == null || authKey == null) return null;

    return "http://${domain}:${port.toString()}/";
  }
}

class AppStaticData {
  static SharedPreferences? sharedPreferences;

  static Future<SharedPreferences> getSharedPreferences() async {
    if (sharedPreferences != null) return Future.value(sharedPreferences);

    sharedPreferences = await SharedPreferences.getInstance();
    return Future.value(sharedPreferences);
  }

  static Map<String, int> TimeFrames = {
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

  static Map<String, int> CandleParts = {"Open": 0, "High": 1, "Low": 2, "Close": 3, "Volume": 4, "HL2": 5, "HLC3": 6, "OC2": 7, "OHL3": 8, "OHLC4": 9, "HLCC4": 10};
}
