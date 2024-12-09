class News {
  final String headline;
  final String source;
  final String snippet;

  News({required this.headline, required this.source, required this.snippet});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      headline: json['title'] ?? "No headline available",
      source: json['source']['name'] ?? "Unknown",
      snippet: json['description'] ?? "No snippet available",
    );
  }
}
