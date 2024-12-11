import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsApiService {
  final String baseUrl = "https://finnhub.io/api/v1";
  final String apiKey = "ctcvropr01qlc0uvo470ctcvropr01qlc0uvo47g";  // Your Finnhub API key

  /// Fetches the latest financial news
  Future<List<News>> fetchFinancialNews() async {
    final url = Uri.parse('$baseUrl/news?category=general&token=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> newsJson = json.decode(response.body);
        return newsJson.map((article) => News.fromJson(article)).toList();
      } else {
        throw Exception("Failed to load news. HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching news: $e");
    }
  }

  /// Fetches company-specific news
  Future<List<News>> fetchCompanyNews(String symbol) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: 7));
    
    final url = Uri.parse(
      '$baseUrl/company-news?symbol=$symbol'
      '&from=${_formatDate(from)}'
      '&to=${_formatDate(now)}'
      '&token=$apiKey'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> newsJson = json.decode(response.body);
        return newsJson.map((article) => News.fromJson(article)).toList();
      } else {
        throw Exception("Failed to load company news. HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching company news: $e");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
