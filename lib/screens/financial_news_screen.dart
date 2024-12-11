import 'package:flutter/material.dart';
import '../widgets/news_card.dart';
import '../services/news_api_service.dart';
import '../models/news.dart';
import 'package:url_launcher/url_launcher.dart';

class FinancialNewsScreen extends StatefulWidget {
  @override
  _FinancialNewsScreenState createState() => _FinancialNewsScreenState();
}

class _FinancialNewsScreenState extends State<FinancialNewsScreen> {
  final NewsApiService _newsService = NewsApiService();
  List<News>? _news;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final news = await _newsService.fetchFinancialNews();
      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading news: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial News'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _news == null || _news!.isEmpty
              ? Center(child: Text('No news available'))
              : RefreshIndicator(
                  onRefresh: _loadNews,
                  child: ListView.builder(
                    itemCount: _news!.length,
                    itemBuilder: (context, index) {
                      final article = _news![index];
                      return NewsCard(
                        headline: article.headline,
                        source: article.source,
                        snippet: article.snippet,
                        onTap: () async {
                          if (await canLaunch(article.url)) {
                            await launch(article.url);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
