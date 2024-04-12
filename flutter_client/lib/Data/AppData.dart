import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
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

const String ISRG_X1 = """-----BEGIN CERTIFICATE-----
MIIGezCCBGOgAwIBAgIQdwcTAExl7j1vrJ/bv5cZ+DANBgkqhkiG9w0BAQwFADBL
MQswCQYDVQQGEwJBVDEQMA4GA1UEChMHWmVyb1NTTDEqMCgGA1UEAxMhWmVyb1NT
TCBSU0EgRG9tYWluIFNlY3VyZSBTaXRlIENBMB4XDTI0MDQxMTAwMDAwMFoXDTI0
MDcxMDIzNTk1OVowITEfMB0GA1UEAxMWaGlyYm9kLmRucy1keW5hbWljLm5ldDCC
ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKAu7N/COQQHVMX5qD8mcTNG
ohaUbU6MGNVFwfqnwvRrJUHvkofZKakgC+AiRP9DOR/dhcMvH+HdbgYON8he/cFy
SFi6GHFQDsRh9TVKGD4gtmUvj99bW/k9cD0eYXSXeC5mQtwjc0ks1n0Gtn7PXxYo
q8++M5umY8LkUrvCDbyCbqbQVdqxMzjH+E+G99V8Q0w7LmDzBNEMsz2ZREbtV59p
f1NWYJ9L200viYAfxFUMw78d6faZX4P/UiWPZhA0iyficTaDcsusUrYVjiASvg3g
E+MMUmW2ybBvXDbjaFgN1faeMMJRbqelobQaaNwl9Z7AItOhnOacinrHdW59KjcC
AwEAAaOCAoMwggJ/MB8GA1UdIwQYMBaAFMjZeGii2Rlo1T1y3l8KPty1hoamMB0G
A1UdDgQWBBSZLirGbAUfN/PQ8blzdSpMWx7OqDAOBgNVHQ8BAf8EBAMCBaAwDAYD
VR0TAQH/BAIwADAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwSQYDVR0g
BEIwQDA0BgsrBgEEAbIxAQICTjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3Rp
Z28uY29tL0NQUzAIBgZngQwBAgEwgYgGCCsGAQUFBwEBBHwwejBLBggrBgEFBQcw
AoY/aHR0cDovL3plcm9zc2wuY3J0LnNlY3RpZ28uY29tL1plcm9TU0xSU0FEb21h
aW5TZWN1cmVTaXRlQ0EuY3J0MCsGCCsGAQUFBzABhh9odHRwOi8vemVyb3NzbC5v
Y3NwLnNlY3RpZ28uY29tMIIBBQYKKwYBBAHWeQIEAgSB9gSB8wDxAHYAdv+IPwq2
+5VRwmHM9Ye6NLSkzbsp3GhCCp/mZ0xaOnQAAAGOy6z+FAAABAMARzBFAiB2ghR1
K0WFJrTNtuuuOm1HiB9hp3ppFJPqfeghUVjB7gIhAL8e4ya4zfVbVaYgkJ+OyQ9C
rjSERWWLlJedBGaFzIxCAHcAPxdLT9ciR1iUHWUchL4NEu2QN38fhWrrwb8ohez4
ZG4AAAGOy6z98AAABAMASDBGAiEA702GMRwelYCBengzKiXAH8vcSinD4onfHMYS
UrKlPPUCIQC1f1nywHnP162dgkS5fkiNAD6GzPYL8oHxP+hbvYiomTAhBgNVHREE
GjAYghZoaXJib2QuZG5zLWR5bmFtaWMubmV0MA0GCSqGSIb3DQEBDAUAA4ICAQBi
AD26VUwZII07rQKaTrLAP7T887gkV7XP0Gu++vlGGfiTHnhtrZmVZ2TkiJm2/bd6
TqD/XYecvT660wx2FqozsBpRVqpd//dtdwbLyT+3VpQEBaYLLp4IdQGeEuSWIezN
7uuomU2M3SD5hs4+xl6I+ONf9JHChwSChvL/3YiMf6QQT2VdzpXzvPgTZM2XC2vY
rxHgtBlRPwy0pvepLjihNUHZFzOULEHyNBo4zNvb6NtdiVtBiPvz4Klm1Wuu7/SW
bOWMmoBi+As9n7vpaeMYQcHUwhXl4ggXmlu461a4GXOedl418TeMj3tnHOslwLYd
kknuDilI3HGfTW03XXjqhRde/sVaVIN6K6tYVxWD4bSPAWDNd3noBeBEFNnautRY
ARwiRWmYNXmRg3D+W0PCawhDcrJxa0kMljmTMkykcxfy3b43uJIxXk02WHOTV5Ql
jRZTWCYvgVpHTwJ8o7sVb4+FRbFFj5uHWqISKlqr70vsHtpsMK+gWLyLASQd6Qak
dV+/rUgBzhv3NgrXuMngBIvDs6crI4WkrK3rHShpPzyD6IpA9ZFMid6hKF8Pr995
tBfuooQP2LETdtXAruPsRp9w3B8TK7ywoiIg5Y4bYmtT/6nfehlTFVubd9XZWvNL
zvfeM/oKNOxt2zGyopyK8syNkcW9Oh3VYyEDfuVtkQ==
-----END CERTIFICATE-----""";

HttpClient customHttpClient({required String cert}) {
  SecurityContext context = SecurityContext.defaultContext;

  try {
    Uint8List bytes = utf8.encode(cert);
    context.setTrustedCertificatesBytes(bytes);
    print('createHttpClient() - cert added!');
  } on TlsException catch (e) {
    if (e.osError?.message != null && e.osError!.message.contains('CERT_ALREADY_IN_HASH_TABLE')) {
      print('createHttpClient() - cert already trusted! Skipping.');
    } else {
      print('createHttpClient().setTrustedCertificateBytes EXCEPTION: $e');
      rethrow;
    }
  }

  return new HttpClient(context: context);
}

/// Use package:http Client with our custom dart:io HttpClient with added
/// LetsEncrypt trusted certificate
http.Client getClient() {
  IOClient ioClient;
  ioClient = IOClient(customHttpClient(cert: ISRG_X1));
  return ioClient;
}
