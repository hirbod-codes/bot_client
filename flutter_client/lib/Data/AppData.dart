import 'package:shared_preferences/shared_preferences.dart';

class AppDataKeys {
  static String BackendDomain = 'BackendDomain';
  static String BackendPort = 'BackendPort';
  static String BackendAuthKey = 'BackendAuthKey';
  static String Options = 'Options';
}

class AppDataRepository {
  static Future<String?> GetBackendUrl() async{
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
}
