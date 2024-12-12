import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/candle.dart';

class StockApiService {
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  static const String _apiKey = 'ctcvropr01qlc0uvo470ctcvropr01qlc0uvo47g';

  Future<Stock> getStockQuote(String symbol) async {
    try {
      // Get quote data
      final quoteResponse = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
      );
      
      // Get company profile for the name
      final profileResponse = await http.get(
        Uri.parse('$_baseUrl/stock/profile2?symbol=$symbol&token=$_apiKey'),
      );

      if (quoteResponse.statusCode != 200 || profileResponse.statusCode != 200) {
        throw Exception('Failed to load stock data');
      }

      final quoteData = json.decode(quoteResponse.body);
      final profileData = json.decode(profileResponse.body);

      return Stock(
        symbol: symbol,
        name: profileData['name'] ?? symbol,
        price: quoteData['c']?.toDouble() ?? 0.0,
        open: quoteData['o']?.toDouble() ?? 0.0,
        high: quoteData['h']?.toDouble() ?? 0.0,
        low: quoteData['l']?.toDouble() ?? 0.0,
        previousClose: quoteData['pc']?.toDouble() ?? 0.0,
        percentChange: quoteData['dp']?.toDouble() ?? 0.0,
      );
    } catch (e) {
      throw Exception('Error fetching stock data: $e');
    }
  }

  Future<List<Candle>> getStockCandles(String symbol, String resolution, int from, int to) async {
    try {
      // Instead of candle data, we'll use the quote endpoint which is available in free tier
      final quoteResponse = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
      );

      if (quoteResponse.statusCode == 200) {
        final data = json.decode(quoteResponse.body);
        // Create a single candle from the quote data
        if (data['c'] != null) {
          return [
            Candle(
              timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              open: (data['o'] as num).toDouble(),
              high: (data['h'] as num).toDouble(),
              low: (data['l'] as num).toDouble(),
              close: (data['c'] as num).toDouble(),
              volume: 0, // Volume not available in quote endpoint
            )
          ];
        }
      }
      print('No quote data available for $symbol: ${quoteResponse.body}');
      return [];
    } catch (e) {
      print('Error fetching quote: $e');
      return [];
    }
  }
}
