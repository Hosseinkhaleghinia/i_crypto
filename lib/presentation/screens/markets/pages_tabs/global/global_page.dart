import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icrypto/core/constants/colors.dart';
import 'package:icrypto/data/models/currency.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:dio/dio.dart';


class GlobalList extends StatefulWidget {
  const GlobalList({Key? key}) : super(key: key);

  @override
  State<GlobalList> createState() => _GlobalListState();
}

class _GlobalListState extends State<GlobalList> {
  List<Currency> cryptoList = [];
  bool isLoading = true;
  var numberFormat = NumberFormat('#,##0.###');

  // نگهداری وضعیت لود شدن نمودارها
  Map<String, bool> chartLoadStatus = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String formatPrice(String priceStr) {
    if (priceStr.endsWith('.0')) {
      priceStr = priceStr.substring(0, priceStr.length - 2);
    }
    return numberFormat.format(double.parse(priceStr));
  }
  Future<void> fetchData() async {
    try {
      // دریافت داده از Coinranking
      var coinrankingResponse = await Dio().get(
        'https://api.coinranking.com/v2/coins',
        options: Options(
          headers: {
            'x-access-token':
                'coinranking7e6eca0ca2205cf78d851cc81b6dcfe8f7e847b76973b9ce',
          },
        ),
      );

      // دریافت داده از Nobitex
      var nobitexResponse = await Dio().post(
        'https://api.nobitex.ir/market/global-stats',
      );

      if (coinrankingResponse.statusCode == 200 &&
          nobitexResponse.statusCode == 200) {
        var coins = coinrankingResponse.data['data']['coins'] as List;
        var nobitexData = nobitexResponse.data;

        setState(() {
          cryptoList = coins.map((coin) {
            // دریافت قیمت کریکن برای هر ارز
            String symbol = coin['symbol'].toString().toLowerCase();
            String price = nobitexData[symbol]?['kraken']?['price'] ??
                coin['price'].toString();

            return Currency(
              coin['name'],
              formatPrice(price),
              double.tryParse(coin['change'].toString()) ?? 0.0,
              coin['marketCap'],
              null,
              // bestSell
              null,
              // bestBuy
              null,
              // dayLow
              null,
              // dayHigh
              null,
              // dayOpen
              null,
              // dayClose
              coin['24hVolume'],
              // volumeSrc
              null,
              // volumeDst
              false,
              // isClosed
              coin['iconUrl'],
              coin['symbol'],
              coin['color'],
            );
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // تابع بررسی وجود نمودار
  Future<bool> checkChartExists(String symbol) async {
    try {
      final response = await Dio().head(
        'https://nobitex.ir/nobitex-cdn/charts/${symbol.toLowerCase()}.svg',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // تابع نمایش نمودار جایگزین
  Widget buildAlternativeChart(double width, String symbol) {
    return Container(
      width: (width - 20) * 0.18,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.show_chart,
          color: Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  // تابع نمایش نمودار
  Widget buildChart(double width, Currency crypto) {
    return FutureBuilder<bool>(
      future: checkChartExists(crypto.symbol ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Container(
            width: (width - 20) * 0.18,
            child: SvgPicture.network(
              'https://nobitex.ir/nobitex-cdn/charts/${crypto.symbol?.toLowerCase()}.svg',
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) =>
                  buildAlternativeChart(width, crypto.symbol ?? ''),
              height: 40,
            ),
          );
        } else {
          // نمایش نمودار جایگزین با استفاده از CustomPaint
          return CustomPaint(
            size: Size((width - 20) * 0.18, 40),
            painter: ChartPainter(
              color: yellow30Safaii
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: ListView.builder(
          itemCount: cryptoList.length,
          itemBuilder: (context, index) {
            final crypto = cryptoList[index];
            return SizedBox(
              height: width * 0.17,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  // بخش اطلاعات ارز
                  SizedBox(
                    width: (width - 20) * 0.45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          crypto.symbol ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Text(
                          ' / USDT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // بخش قیمت
                  SizedBox(
                    width: (width - 20) * 0.29,
                    child: Text(
                      crypto.latestPrice ?? '0',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: (width - 20) * 0.08),

                  // بخش نمودار با مدیریت خطا
                  buildChart(width, crypto),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// کلاس نقاش نمودار جایگزین
class ChartPainter extends CustomPainter {
  final Color color;

  ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // شروع از سمت چپ
    path.moveTo(0, size.height * 0.5);

    // ایجاد خطوط مستقیم و تیز به جای منحنی
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
