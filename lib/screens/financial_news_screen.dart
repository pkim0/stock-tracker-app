import 'package:flutter/material.dart';
import '../widgets/news_card.dart';

class FinancialNewsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> news = [
    {
      "headline": "Stock Market Hits All-Time High",
      "source": "Bloomberg",
      "snippet": "The stock market reached new heights today as...",
    },
    {
      "headline": "Tesla Unveils New Electric Car",
      "source": "Reuters",
      "snippet": "Tesla has introduced a revolutionary electric...",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Financial News')),
      body: ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          final article = news[index];
          return NewsCard(
            headline: article['headline'],
            source: article['source'],
            snippet: article['snippet'],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening: ${article['headline']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
