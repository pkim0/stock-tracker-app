import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsApiService {
  final String baseUrl = "https://newsapi.org/v2";
  final String apiKey = "41601b163b4140949c34a53320848a6f";

  /// Fetches the latest financial news related to stocks.
  Future<List<dynamic>> fetchFinancialNews() async {
    final url = Uri.parse(
        '$baseUrl/everything?q=stocks&language=en&sortBy=publishedAt&apiKey=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles']; // Returns a list of news articles
      } else {
        throw Exception("Failed to load financial news. HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching financial news: $e");
    }
  }
}
