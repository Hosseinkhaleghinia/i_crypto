class Currency {
  String? name;
  String? latestPrice; // Changed from String to double
  double? dayChange;
  String? marketCap;
  String? bestSell;
  String? bestBuy;
  String? dayLow;
  String? dayHigh;
  String? dayOpen;
  String? dayClose;
  String? volumeSrc;
  String? volumeDst;
  bool? isClosed;
  String? iconUrl;
  String? symbol;
  String? error;
  String? color;

  Currency(
      this.name,
      this.latestPrice,
      this.dayChange,
      this.marketCap,
      this.bestSell,
      this.bestBuy,
      this.dayLow,
      this.dayHigh,
      this.dayOpen,
      this.dayClose,
      this.volumeSrc,
      this.volumeDst,
      this.isClosed,
      this.iconUrl,
      this.symbol,
      this.color);

  factory Currency.error(String errorMessage) {
    return Currency(
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    )..error = errorMessage;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latestPrice': latestPrice,
      'dayChange': dayChange,
      'marketCap': marketCap,
      'volumeSrc': volumeSrc,
      'iconUrl': iconUrl,
      'symbol': symbol,
      'color': color,
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      json['name'],
      json['latestPrice'],
      json['dayChange'],
      json['marketCap'],
      null, null, null, null, null, null,
      json['volumeSrc'],
      null, null,
      json['iconUrl'],
      json['symbol'],
      json['color'],
    );
  }
}
