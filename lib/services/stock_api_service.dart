import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/candle.dart';

class StockApiService {
  final String baseUrl = "https://finnhub.io/api/v1";
  final String apiKey = "ctcvropr01qlc0uvo470ctcvropr01qlc0uvo47g";

  /// Fetch real-time stock quote data for a given stock symbol.
  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final url = Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body); // Returns the JSON as a Map
      } else {
        throw Exception("Failed to load stock data. HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching stock data: $e");
    }
  }

  /// Fetch historical data for a stock symbol over the past 30 days.
  Future<Map<String, dynamic>> fetchHistoricalData(String symbol) async {
    final url = Uri.parse(
        '$baseUrl/stock/candle?symbol=$symbol&resolution=D&count=30&token=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body); // Returns the JSON as a Map
      } else {
        throw Exception(
            "Failed to load historical data. HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching historical data: $e");
    }
  }

  Future<Stock> getStockQuote(String symbol) async {
    try {
      final quoteData = await fetchStockData(symbol);
      final companyName = await _getCompanyName(symbol);
      
      return Stock(
        symbol: symbol,
        name: companyName,
        price: (quoteData['c'] ?? 0.0).toDouble(),
        percentChange: (quoteData['dp'] ?? 0.0).toDouble(),
        change: (quoteData['d'] ?? 0.0).toDouble(),
        open: (quoteData['o'] ?? 0.0).toDouble(),
        high: (quoteData['h'] ?? 0.0).toDouble(),
        low: (quoteData['l'] ?? 0.0).toDouble(),
        previousClose: (quoteData['pc'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      throw Exception("Error getting stock quote: $e");
    }
  }

  Future<List<Candle>> getStockCandles(String symbol, String interval, int from, int to) async {
    try {
      // Since we don't have access to candle data, let's use quote data to create a simple chart
      final quoteData = await fetchStockData(symbol);
      
      // Create a list of simulated price points using the available data
      final now = DateTime.now();
      List<Candle> candles = [];
      
      // Use the current price and previous close to create two data points
      final currentPrice = (quoteData['c'] ?? 0.0).toDouble();
      final openPrice = (quoteData['o'] ?? 0.0).toDouble();
      final highPrice = (quoteData['h'] ?? 0.0).toDouble();
      final lowPrice = (quoteData['l'] ?? 0.0).toDouble();
      final prevClose = (quoteData['pc'] ?? 0.0).toDouble();

      // Create candles for the last few data points
      candles.add(Candle(
        timestamp: (now.subtract(Duration(days: 1)).millisecondsSinceEpoch ~/ 1000),
        open: prevClose,
        high: prevClose * 1.01,
        low: prevClose * 0.99,
        close: prevClose,
        volume: 0,
      ));

      candles.add(Candle(
        timestamp: now.millisecondsSinceEpoch ~/ 1000,
        open: openPrice,
        high: highPrice,
        low: lowPrice,
        close: currentPrice,
        volume: 0,
      ));

      return candles;
    } catch (e) {
      print('Exception in getStockCandles: $e');
      return [];
    }
  }

  Future<String> _getCompanyName(String symbol) async {
    try {
      final url = Uri.parse('$baseUrl/stock/profile2?symbol=$symbol&token=$apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['name'] ?? symbol;
      }
      return symbol;
    } catch (e) {
      return symbol;
    }
  }
}
