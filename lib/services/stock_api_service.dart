import 'dart:convert';
import 'package:http/http.dart' as http;

class StockApiService {
  final String baseUrl = "https://finnhub.io/api/v1";
  final String apiKey = "ctbjmupr01qvslqun1t0ctbjmupr01qvslqun1tg";

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
}
