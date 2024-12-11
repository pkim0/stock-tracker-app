import 'candle.dart';

class Stock {
  final String name;
  final String symbol;
  final double price;
  final double change;
  final double percentChange;
  final double high;
  final double low;
  final double open;
  final double previousClose;
  List<Candle>? candleData;

  Stock({
    required this.name,
    required this.symbol,
    required this.price,
    this.change = 0.0,
    this.percentChange = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.open = 0.0,
    this.previousClose = 0.0,
    this.candleData,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      name: json['name'] ?? "Unknown",
      symbol: json['symbol'],
      price: (json['c'] ?? 0.0).toDouble(),
      change: (json['d'] ?? 0.0).toDouble(),
      percentChange: (json['dp'] ?? 0.0).toDouble(),
      high: (json['h'] ?? 0.0).toDouble(),
      low: (json['l'] ?? 0.0).toDouble(),
      open: (json['o'] ?? 0.0).toDouble(),
      previousClose: (json['pc'] ?? 0.0).toDouble(),
    );
  }
}
