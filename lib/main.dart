import 'package:flutter/material.dart';
import 'package:icrypto/data/services/cache_service.dart';
import 'package:icrypto/presentation/providers/crypto_data_provider.dart';
import 'package:icrypto/presentation/providers/kraken_data_provider.dart';
import 'package:icrypto/presentation/screens/markets/main_markets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cacheService = CacheService(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CryptoDataProvider(cacheService)),
        //ChangeNotifierProvider(create: (_) => KrakenDataProvider()),
      ],
      child:  Application(),
    ),
  );
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'vazir'),
    home: MainMarkets(),
    );
  }
}
/**
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart         # تنظیمات کلی اپلیکیشن
│   │   ├── api_config.dart         # تنظیمات مربوط به API
│   │   └── theme_config.dart       # تنظیمات مربوط به تم
│   ├── constants/
│   │   └── app_constants.dart      # ثابت‌های برنامه
│   └── utils/
│       └── retry_helper.dart       # توابع کمکی برای retry
├── data/
│   ├── models/
│   │   └── crypto_state.dart
│   ├── repositories/
│   │   └── crypto_repository.dart
│   └── services/
│       ├── coinranking_api_server.dart
│       └── nobitex_api_server.dart
├── presentation/
│   ├── providers/
│   │   └── crypto_data_provider.dart
│   ├── screens/
│   │   └── crypto_stream_test_screen.dart
│   └── widgets/
│       └── crypto_stream_test_widget.dart
└── main.dart
**/