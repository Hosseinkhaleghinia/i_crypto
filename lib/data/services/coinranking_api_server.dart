import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:icrypto/core/config/api_config.dart';

class CoinrankingServer {
  Future<dynamic> getState() async {
    var headers = {
      'x-access-token': 'coinranking7e6eca0ca2205cf78d851cc81b6dcfe8f7e847b76973b9ce',
    };

    try {
      var dio = Dio();
      var response = await dio.get(
        'https://api.coinranking.com/v2/coins',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        // اینجا می‌توانید داده‌ها را پردازش کنید
        print(data); // نمایش اطلاعات دریافت‌شده
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}