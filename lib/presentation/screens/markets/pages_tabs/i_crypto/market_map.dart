import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icrypto/core/constants/colors.dart';
import 'package:icrypto/data/models/currency.dart';
import 'package:icrypto/presentation/providers/crypto_data_provider.dart';
import 'package:provider/provider.dart';

class MarketMapWidget extends StatefulWidget {
  final CurrencyType currencyType;
  final double padding;

  MarketMapWidget({
    Key? key,
    required this.currencyType,
    this.padding = 2.0,
  }) : super(key: key);

  @override
  State<MarketMapWidget> createState() => _MarketMapWidgetState();
}

class _MarketMapWidgetState extends State<MarketMapWidget> {
  late CurrencyType _currencyType;
  OverlayEntry? _overlayEntry;
  Currency? _selectedCrypto;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _currencyType = widget.currencyType;
  }

  void _toggleCurrencyType() {
    setState(() {
      _currencyType = _currencyType == CurrencyType.tether
          ? CurrencyType.irt
          : CurrencyType.tether;
      _removeOverlay();
    });
  }

  double _parseVolume(String volume) {
    return double.tryParse(volume.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoDataProvider>(
      builder: (context, provider, child) {
        // دریافت داده‌ها بر اساس نوع ارز
        final data = _currencyType == CurrencyType.tether
            ? provider.getTetherList()
            : provider.getIRTList();

        // مرتب‌سازی داده‌ها بر اساس حجم معاملات
        final sortedData = List<Currency>.from(data)
          ..sort((a, b) {
            final aVolume = _parseVolume(a.volumeSrc!);
            final bVolume = _parseVolume(b.volumeSrc!);
            return bVolume.compareTo(aVolume);
          });

        return Scaffold(
          backgroundColor: blue100Safaii,
          appBar: AppBar(
            backgroundColor: blue100Safaii,
            elevation: 0,
            title: Text(
              _currencyType == CurrencyType.tether
                  ? 'نقشه بازار تتری'
                  : 'نقشه بازار تومانی',
              style: TextStyle(fontSize: 16),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Transform.scale(
                  scaleX: -1,
                  child: Icon(Icons.arrow_back),
                ),
              )
            ],
            leading: IconButton(
                onPressed: _toggleCurrencyType,
                icon: _currencyType == CurrencyType.tether
                    ? SvgPicture.asset(
                  'images/iran.svg',
                  width: 25,
                  height: 25,
                )
                    : SvgPicture.asset(
                  'images/usdt.svg',
                  width: 25,
                  height: 25,
                )),
          ),
          body: provider.isLoading
              ? Center(
              child: SpinKitCircle(
                size: 70,
                color: backgrand,
              ))
              : Padding(
            padding: EdgeInsets.all(0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxes = _calculateBoxSizes(
                  sortedData,
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                return Stack(
                  children: [
                    for (int i = 0; i < boxes.length; i++)
                      Positioned(
                        left: boxes[i].left,
                        top: boxes[i].top,
                        width: boxes[i].width,
                        height: boxes[i].height,
                        child: Padding(
                          padding: EdgeInsets.all(widget.padding),
                          child: _buildBox(
                            sortedData[i],
                            boxes[i].height,
                            _currencyType,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Currency crypto, TapDownDetails details) {
    final boxSize = context.size ?? Size.zero;

    // اگر روی همان باکس قبلی کلیک شده
    if (_selectedCrypto?.symbol == crypto.symbol) {
      _removeOverlay();
    } else {
      // اگر روی باکس جدید کلیک شده، مستقیماً overlay جدید را نمایش بده
      _showDetailsOverlay(crypto, details.globalPosition, boxSize);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _selectedCrypto = null;
      _tapPosition = null;
    });
  }

  void _showDetailsOverlay(Currency crypto, Offset tapPosition, Size boxSize) {
    // اگر crypto جدید با crypto قبلی یکسان است، overlay را حذف کن
    if (_selectedCrypto?.symbol == crypto.symbol) {
      _removeOverlay();
      return;
    }

    // قبل از نمایش overlay جدید، overlay قبلی را حذف کن
    _overlayEntry?.remove();

    setState(() {
      _selectedCrypto = crypto;
      _tapPosition = tapPosition;
    });

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (_) => _removeOverlay(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: _calculateOverlayPosition(tapPosition.dx, size.width, 200.0),
            top: _calculateOverlayPosition(tapPosition.dy, size.height, 150.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crypto.symbol ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _detailRow('قیمت:', '${_getPriceWithCurrency(crypto)}'),
                    _detailRow('تغییر روزانه:', '${crypto.dayChange ?? 0}%'),
                    _detailRow('حجم معاملات:', crypto.volumeSrc ?? '0'),
                    _detailRow('حجم معاملات مقصد:', crypto.volumeDst ?? '0'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  String _getPriceWithCurrency(Currency crypto) {
    if (_currencyType == CurrencyType.tether) {
      return '\$${crypto.latestPrice}';
    } else {
      return '${crypto.latestPrice} تومان';
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOverlayPosition(
      double tapPos, double maxSize, double overlaySize) {
    double position = tapPos - (overlaySize / 2);

    if (position < 10) {
      position = 10;
    } else if (position + overlaySize > maxSize - 10) {
      position = maxSize - overlaySize - 10;
    }

    return position;
  }

  Widget _buildBox(Currency data, double boxHeight, CurrencyType currencyType) {
    String pricePrefix = currencyType == CurrencyType.tether ? '\$' : '';
    String priceSuffix = currencyType == CurrencyType.irt ? ' تومان' : '';
    final safeDayChange = data.dayChange ?? 0;
    final isSelected = _selectedCrypto?.symbol == data.symbol;

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final boxSize = context.size ?? Size.zero;
        _showDetailsOverlay(data, details.globalPosition, boxSize);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey[700]
              : _getBackgroundColor(safeDayChange),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final TextStyle style = TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : null,
            );
            String displayText = '';

            if (constraints.maxWidth > 200) {
              displayText =
              '${data.symbol!}\n$pricePrefix${data.latestPrice}$priceSuffix\n${safeDayChange}';
            } else if (constraints.maxWidth > 150) {
              displayText =
              '${data.symbol!}\n$pricePrefix${data.latestPrice}$priceSuffix';
            } else {
              displayText = _getMinimalText(data.symbol!);
            }

            return Center(
              child: Container(
                width: constraints.maxWidth,
                child: Text(
                  _truncateText(
                      displayText, constraints.maxWidth - 16, style, context),
                  style: style,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

// تابع جدید برای گرفتن حداقل متن قابل نمایش
  String _getMinimalText(String symbol) {
    if (symbol.isEmpty) return '';
    // اگر متن تک کاراکتری باشد، همان را برمی‌گرداند
    if (symbol.length <= 1) return symbol;
    // در غیر این صورت، اولین حرف را برمی‌گرداند
    return symbol[0];
  }

  String _truncateText(
      String text, double maxWidth, TextStyle style, BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.rtl, // تغییر جهت متن برای پشتیبانی از فارسی
      textAlign: TextAlign.center, // تنظیم text painter به صورت وسط‌چین
    );

    textPainter.layout(minWidth: 0, maxWidth: double.infinity);

    if (textPainter.width <= maxWidth) {
      return text;
    }

    int low = 0;
    int high = text.length;
    String result = '';

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      String truncated = text.substring(0, mid) + '...';
      textPainter.text = TextSpan(text: truncated, style: style);
      textPainter.layout(minWidth: 0, maxWidth: double.infinity);

      if (textPainter.width <= maxWidth) {
        result = truncated;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  }

  double _calculateTotalVolume(List<Currency> data) {
    return data.fold(
        0.0, (sum, crypto) => sum + _parseVolume(crypto.volumeSrc!));
  }

  List<BoxPosition> _calculateBoxSizes(
      List<Currency> data,
      double containerWidth,
      double containerHeight,
      ) {
    final List<BoxPosition> positions = [];
    double currentX = 0;
    double currentY = 0;
    double remainingWidth = containerWidth;
    double remainingHeight = containerHeight;

    // تغییر به محاسبه کل حجم معاملات
    final totalVolume = _calculateTotalVolume(data);

    for (int i = 0; i < data.length; i++) {
      // استفاده از حجم معاملات به جای مارکت کپ
      final volume = _parseVolume(data[i].volumeSrc!);
      final ratio = totalVolume > 0 ? volume / totalVolume : 0.0;
      final area = containerWidth * containerHeight * ratio;

      double width, height;
      if (remainingWidth > remainingHeight) {
        width = area / remainingHeight;
        height = remainingHeight;
      } else {
        height = area / remainingWidth;
        width = remainingWidth;
      }

      positions.add(BoxPosition(
        left: currentX,
        top: currentY,
        width: width,
        height: height,
      ));

      if (remainingWidth > remainingHeight) {
        currentX += width;
        remainingWidth -= width;
      } else {
        currentY += height;
        remainingHeight -= height;
      }
    }

    return positions;
  }

  Color _getBackgroundColor(double change) {
    if (change == 0) {
      return greyMarket;
    }

    // برای تغییرات مثبت
    if (change > 0) {
      if (change >= 5) {
        return green100Market; // تغییرات شدید مثبت
      } else if (change >= 2) {
        return green50Market; // تغییرات متوسط مثبت
      } else {
        return green20Market; // تغییرات کم مثبت
      }
    }

    // برای تغییرات منفی
    else {
      if (change <= -5) {
        return red100Market; // تغییرات شدید منفی
      } else if (change <= -2) {
        return red50Market; // تغییرات متوسط منفی
      } else {
        return red20Market; // تغییرات کم منفی
      }
    }
  }
}

class BoxPosition {
  final double left;
  final double top;
  final double width;
  final double height;

  BoxPosition({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
