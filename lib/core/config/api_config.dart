class ApiConfig {
  static const String coinrankingToken = String.fromEnvironment(
    'COINRANKING_TOKEN',
    defaultValue: '',
  );

  // اضافه کردن توکن‌های دیگر در صورت نیاز
  static bool get hasValidConfig => coinrankingToken.isNotEmpty;
}