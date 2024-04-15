import 'package:shared_preferences/shared_preferences.dart';

class AppDataKeys {
  static String backendDomain = 'BackendDomain';
  static String backendPort = 'BackendPort';
  static String backendAuthKey = 'BackendAuthKey';
  static String options = 'Options';
}

class AppDataRepository {
  static Future<String?> GetBackendUrl() async {
    String? domain = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.backendDomain);
    int? port = (await AppStaticData.getSharedPreferences()).getInt(AppDataKeys.backendPort);
    String? authKey = (await AppStaticData.getSharedPreferences()).getString(AppDataKeys.backendAuthKey);

    if (domain == null || port == null || authKey == null) return null;

    return "${domain}:${port.toString()}/bot/";
  }
}

class AppStaticData {
  static SharedPreferences? sharedPreferences;

  static Future<SharedPreferences> getSharedPreferences() async {
    if (sharedPreferences != null) return Future.value(sharedPreferences);

    sharedPreferences = await SharedPreferences.getInstance();
    return Future.value(sharedPreferences);
  }

  static const String minute = "1m";
  static const String threeMinute = "3m";
  static const String fiveMinute = "5m";
  static const String fifteenMinute = "15m";
  static const String thirtyMinute = "30m";
  static const String hour = "1h";
  static const String fourHour = "4h";
  static const String day = "1D";
  static const String week = "1W";
  static const String month = "1M";
  static const String year = "1Y";

  static Map<String, int> timeFrames = {
    minute: 60,
    threeMinute: 3 * 60,
    fiveMinute: 5 * 60,
    fifteenMinute: 15 * 60,
    thirtyMinute: 30 * 60,
    hour: 60 * 60,
    fourHour: 4 * 60 * 60,
    day: 24 * 60 * 60,
    week: 7 * 24 * 60 * 60,
    month: 30 * 24 * 60 * 60,
    year: 12 * 30 * 24 * 60 * 60,
  };

  static Map<String, int> candleParts = {"Open": 0, "High": 1, "Low": 2, "Close": 3, "Volume": 4, "HL2": 5, "HLC3": 6, "OC2": 7, "OHL3": 8, "OHLC4": 9, "HLCC4": 10};
}
