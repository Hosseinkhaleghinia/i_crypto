import 'dart:convert';

import 'package:dio/dio.dart';

class NobitexApiServer{
  var baseUrl = 'https://api.nobitex.ir/';
  var token =  '';

  Future<dynamic> getState(dstCurrency) async {
    var data = FormData.fromMap({
      'srcCurrency': '',
      'dstCurrency': dstCurrency
    });

    var dio = Dio();
    var response = await dio.request(
      '${baseUrl}market/stats',
      options: Options(
        method: 'POST',
      ),
      data: data,
    );
    var state = response.data;
    //var data2 = await state['stats']['btc-rls']['latest'];
    return state;
  }

  Future<dynamic> getProfile() async{
    var headers = {
      'Authorization': 'Token $token'
    };
    var dio = Dio();
    var response = await dio.request(
      'https://api.nobitex.ir/users/profile',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    // var firstName = response.data['profile']['firstName'];
    // var lastName = response.data['profile']['lastName'];
    var profile = response.data;
    return profile;
  }
}