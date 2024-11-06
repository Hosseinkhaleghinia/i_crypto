import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icrypto/data/services/cache_service.dart';
import 'package:intl/intl.dart';
import 'package:icrypto/data/models/currency.dart';
import 'package:icrypto/data/services/coinranking_api_server.dart';
import 'package:icrypto/data/services/nobitex_api_server.dart';

enum SortOrder { none, ascending, descending }

enum CurrencyType { tether, irt }

class CryptoDataProvider with ChangeNotifier {
  final CacheService _cacheService;

  final CoinrankingServer _cryptoCoinRanking = CoinrankingServer();
  final NobitexApiServer _cryptoNobitex = NobitexApiServer();

  final _tetherController = StreamController<List<Currency>>.broadcast();
  final _irtController = StreamController<List<Currency>>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  CryptoDataProvider(this._cacheService);

  List<Currency> _tetherData = [];
  List<Currency> _irtData = [];
  List<Currency> _filteredTetherData = [];
  List<Currency> _filteredIrtData = [];

  bool _isLoading = true;
  String? _error;
  CurrencyType _selectedCurrency = CurrencyType.irt;

  final numberFormat = NumberFormat('#,##0.###');

  Stream<List<Currency>> get tetherStream => _tetherController.stream;
  Stream<List<Currency>> get irtStream => _irtController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // تعریف متغیرهای نگهدارنده وضعیت فیلترها برای هر نوع ارز
  Map<CurrencyType, SortOrder> _priceOrder = {
    CurrencyType.tether: SortOrder.none,
    CurrencyType.irt: SortOrder.none,
  };
  Map<CurrencyType, SortOrder> _changeOrder = {
    CurrencyType.tether: SortOrder.none,
    CurrencyType.irt: SortOrder.none,
  };
  Map<CurrencyType, SortOrder> _volumeOrder = {
    CurrencyType.tether: SortOrder.none,
    CurrencyType.irt: SortOrder.none,
  };
  Map<CurrencyType, SortOrder> _nameOrder = {
    CurrencyType.tether: SortOrder.none,
    CurrencyType.irt: SortOrder.none,
  };

  // گترها
  List<Currency> getTetherList() {
    final list = _filteredTetherData.isEmpty ? _tetherData : _filteredTetherData;
    _tetherController.add(list);
    return list;
  }
  List<Currency> getIRTList() {
    final list = _filteredIrtData.isEmpty ? _irtData : _filteredIrtData;
    _irtController.add(list);
    return list;
  }
  bool get isLoading => _isLoading;

  void setSelectedCurrency(CurrencyType type) {
    _selectedCurrency = type;
    notifyListeners();
  }

  // متدهای کمکی برای فرمت‌دهی
  String formatPrice(String priceStr) {
    if (priceStr.endsWith('.0')) {
      priceStr = priceStr.substring(0, priceStr.length - 2);
    }
    return numberFormat.format(double.parse(priceStr));
  }

  String formatVolumeDst(String volume) {
    if (volume != null) {
      double? volumeSrt = double.tryParse(volume.toString());
      volume = numberFormat.format(volumeSrt);
    }
    return volume;
  }

  // متد مرتب‌سازی بر اساس قیمت
  void sortByPrice(SortOrder order) {
    _priceOrder[_selectedCurrency] = order;
    _changeOrder[_selectedCurrency] = SortOrder.none;
    _volumeOrder[_selectedCurrency] = SortOrder.none;
    _nameOrder[_selectedCurrency] = SortOrder.none;

    List<Currency> dataToSort = _selectedCurrency == CurrencyType.tether
        ? List.from(_tetherData)
        : List.from(_irtData);

    if (order != SortOrder.none) {
      dataToSort.sort((a, b) {
        double priceA = double.tryParse(a.latestPrice?.replaceAll(',', '') ?? '0') ?? 0;
        double priceB = double.tryParse(b.latestPrice?.replaceAll(',', '') ?? '0') ?? 0;
        return order == SortOrder.ascending
            ? priceA.compareTo(priceB)
            : priceB.compareTo(priceA);
      });
    }

    if (_selectedCurrency == CurrencyType.tether) {
      _filteredTetherData = dataToSort;
      _tetherController.add(_filteredTetherData);
    } else {
      _filteredIrtData = dataToSort;
      _irtController.add(_filteredIrtData);
    }

    notifyListeners();
  }

  void sortByDayChange(SortOrder order) {
    _changeOrder[_selectedCurrency] = order;
    _priceOrder[_selectedCurrency] = SortOrder.none;
    _volumeOrder[_selectedCurrency] = SortOrder.none;
    _nameOrder[_selectedCurrency] = SortOrder.none;

    List<Currency> dataToSort = _selectedCurrency == CurrencyType.tether
        ? List.from(_tetherData)
        : List.from(_irtData);

    if (order != SortOrder.none) {
      dataToSort.sort((a, b) {
        double changeA = a.dayChange ?? 0;
        double changeB = b.dayChange ?? 0;
        return order == SortOrder.ascending
            ? changeA.compareTo(changeB)
            : changeB.compareTo(changeA);
      });
    }


    if (_selectedCurrency == CurrencyType.tether) {
      _filteredTetherData = dataToSort;
      _tetherController.add(_filteredTetherData);
    } else {
      _filteredIrtData = dataToSort;
      _irtController.add(_filteredIrtData);
    }

    notifyListeners();
  }

  void sortByVolume(SortOrder order) {
    _volumeOrder[_selectedCurrency] = order;
    _priceOrder[_selectedCurrency] = SortOrder.none;
    _changeOrder[_selectedCurrency] = SortOrder.none;
    _nameOrder[_selectedCurrency] = SortOrder.none;

    List<Currency> dataToSort = _selectedCurrency == CurrencyType.tether
        ? List.from(_tetherData)
        : List.from(_irtData);

    if (order != SortOrder.none) {
      dataToSort.sort((a, b) {
        double volumeA =
            double.tryParse(a.volumeSrc?.replaceAll(',', '') ?? '0') ?? 0;
        double volumeB =
            double.tryParse(b.volumeSrc?.replaceAll(',', '') ?? '0') ?? 0;
        return order == SortOrder.ascending
            ? volumeA.compareTo(volumeB)
            : volumeB.compareTo(volumeA);
      });

    }

    if (_selectedCurrency == CurrencyType.tether) {
      _filteredTetherData = dataToSort;
      _tetherController.add(_filteredTetherData);

    } else {
      _filteredIrtData = dataToSort;
      _irtController.add(_filteredIrtData);

    }

    notifyListeners();
  }

  void sortByName(SortOrder order) {
    _nameOrder[_selectedCurrency] = order;
    _priceOrder[_selectedCurrency] = SortOrder.none;
    _volumeOrder[_selectedCurrency] = SortOrder.none;
    _changeOrder[_selectedCurrency] = SortOrder.none;

    List<Currency> dataToSort = _selectedCurrency == CurrencyType.tether
        ? List.from(_tetherData)
        : List.from(_irtData);

    if (order != SortOrder.none) {
      dataToSort.sort((a, b) {
        return order == SortOrder.ascending
            ? a.symbol!.compareTo(b.symbol!)
            : b.symbol!.compareTo(a.symbol!);
      });
    }

    if (_selectedCurrency == CurrencyType.tether) {
      _filteredTetherData = dataToSort;
      _tetherController.add(_filteredTetherData);

    } else {
      _filteredIrtData = dataToSort;
      _irtController.add(_filteredIrtData);

    }

    notifyListeners();
  }

  // بقیه متدهای مرتب‌سازی به همین شکل آپدیت می‌شوند...

  // متد اصلی دریافت داده‌ها
  Future<void> fetchCoins() async {
    try {
      _setLoading(true);
      _setError(null);

      // Try to load cached data first
      if (_cacheService.isCacheValid()) {
        final cachedData = await _cacheService.getCachedData();
        _tetherData = cachedData['tether'] ?? [];
        _irtData = cachedData['irt'] ?? [];
        _updateStreams();
      }

      // Wrap API calls in Future.wait to handle concurrent requests
      final results = await Future.wait([
        _cryptoCoinRanking.getState().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Connection timeout'),
        ),
        _cryptoNobitex.getState('rls').timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Connection timeout'),
        ),
        _cryptoNobitex.getState('usdt').timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Connection timeout'),
        ),
      ]);

      // Process API data
      if (results.every((result) => result != null)) {
        await _processApiData(results[0], results[1], results[2]);

        // Cache the new data
        await _cacheService.cacheCryptoData(
          tetherData: _tetherData,
          irtData: _irtData,
        );
      } else {
        throw Exception('Invalid API response received');
      }

    } catch (e, stackTrace) {
      print('Error fetching crypto data: $e');
      print('Stack trace: $stackTrace');

      // If we have cached data, don't show error
      final hasCache = _tetherData.isNotEmpty || _irtData.isNotEmpty;
      if (!hasCache) {
        String errorMessage = _getReadableErrorMessage(e);
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  bool _validateApiResponse(Map<String, dynamic> coinRanking, Map<String, dynamic> nobitexIRT, Map<String, dynamic> nobitexUSDT) {
    try {
      return coinRanking['data']?['coins'] is List &&
          nobitexIRT['stats'] is Map<String, dynamic> &&
          nobitexUSDT['stats'] is Map<String, dynamic>;
    } catch (e) {
      return false;
    }
  }

  Future<void> _processApiData(
      Map<String, dynamic> resultCoinRanking,
      Map<String, dynamic> resultNobitexIRT,
      Map<String, dynamic> resultNobitexUSDT,
      ) async {
    final nobitexStatsIRT = resultNobitexIRT['stats'] as Map<String, dynamic>;
    final nobitexStatsUSDT = resultNobitexUSDT['stats'] as Map<String, dynamic>;
    final coins = resultCoinRanking['data']['coins'] as List;

    _tetherData = [];
    _irtData = [];

    for (var coin in coins) {
      try {
        final symbol = coin['symbol'].toString().toLowerCase();
        await _processIRTData(coin, symbol, nobitexStatsIRT);
        await _processTetherData(coin, symbol, nobitexStatsUSDT);
      } catch (e) {
        print('Error processing coin ${coin['symbol']}: $e');
        continue; // Skip this coin but continue processing others
      }
    }

    _updateStreams();
  }

  Future<void> _processIRTData(Map<String, dynamic> coin, String symbol, Map<String, dynamic> nobitexStatsIRT) async {
    final nobitexSymbolIRT = '$symbol-rls';
    if (nobitexStatsIRT.containsKey(nobitexSymbolIRT)) {
      final cryptoStats = nobitexStatsIRT[nobitexSymbolIRT];
      var rawPrice = double.tryParse(cryptoStats['latest'].toString());
      String? formattedPrice;

      if (rawPrice != null) {
        var dividedPrice = (rawPrice / 10).toString();
        formattedPrice = formatPrice(dividedPrice);
      }

      _irtData.add(Currency(
        coin['name'],
        formattedPrice,
        double.tryParse(cryptoStats['dayChange'].toString()),
        coin['marketCap'],
        null, null, null, null, null, null,
        formatVolumeDst(cryptoStats['volumeDst'].toString()),
        null, null,
        coin['iconUrl'],
        coin['symbol'],
        coin['color'],
      ));
    }
  }

  Future<void> _processTetherData(Map<String, dynamic> coin, String symbol, Map<String, dynamic> nobitexStatsUSDT) async {
    final nobitexSymbolUSDT = '$symbol-usdt';
    if (nobitexStatsUSDT.containsKey(nobitexSymbolUSDT)) {
      final cryptoStats = nobitexStatsUSDT[nobitexSymbolUSDT];
      String? formattedPrice = formatPrice(cryptoStats['latest'].toString());

      _tetherData.add(Currency(
        coin['name'],
        formattedPrice,
        double.tryParse(cryptoStats['dayChange'].toString()),
        coin['marketCap'],
        null, null, null, null, null, null,
        formatVolumeDst(cryptoStats['volumeDst'].toString()),
        null, null,
        coin['iconUrl'],
        coin['symbol'],
        coin['color'],
      ));
    }
  }

  void _updateStreams() {
    _filteredTetherData = List.from(_tetherData);
    _filteredIrtData = List.from(_irtData);

    _tetherController.add(_tetherData);
    _irtController.add(_irtData);
  }

  String _getReadableErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection timeout. Please check your internet connection and try again.';
    } else if (error.toString().contains('XMLHttpRequest')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }
    return 'An unexpected error occurred. Please try again later.';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _loadingController.add(loading);
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _errorController.add(error);
    notifyListeners();
  }

  @override
  void dispose() {
    _tetherController.close();
    _irtController.close();
    _loadingController.close();
    _errorController.close();
    super.dispose();
  }
}
