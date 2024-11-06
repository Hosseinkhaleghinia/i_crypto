import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icrypto/data/models/currency.dart';

class CacheService {
  static const String TETHER_KEY = 'tether_data';
  static const String IRT_KEY = 'irt_data';
  static const String LAST_UPDATE_KEY = 'last_update';

  final SharedPreferences prefs;

  CacheService(this.prefs);

  Future<void> cacheCryptoData({
    required List<Currency> tetherData,
    required List<Currency> irtData,
  }) async {
    final now = DateTime.now().toIso8601String();

    await Future.wait([
      prefs.setString(TETHER_KEY, jsonEncode(tetherData.map((c) => c.toJson()).toList())),
      prefs.setString(IRT_KEY, jsonEncode(irtData.map((c) => c.toJson()).toList())),
      prefs.setString(LAST_UPDATE_KEY, now),
    ]);
  }

  Future<Map<String, List<Currency>>> getCachedData() async {
    final tetherJson = prefs.getString(TETHER_KEY);
    final irtJson = prefs.getString(IRT_KEY);

    return {
      'tether': tetherJson != null
          ? List<Currency>.from(jsonDecode(tetherJson).map((x) => Currency.fromJson(x)))
          : [],
      'irt': irtJson != null
          ? List<Currency>.from(jsonDecode(irtJson).map((x) => Currency.fromJson(x)))
          : [],
    };
  }

  bool isCacheValid() {
    final lastUpdate = prefs.getString(LAST_UPDATE_KEY);
    if (lastUpdate == null) return false;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    final now = DateTime.now();

    // Consider cache valid if less than 5 minutes old
    return now.difference(lastUpdateTime).inMinutes < 5;
  }
}
