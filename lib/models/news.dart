class News {
  final String headline;
  final String source;
  final String snippet;
  final String url;
  final DateTime datetime;

  News({
    required this.headline,
    required this.source,
    required this.snippet,
    required this.url,
    required this.datetime,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      headline: json['headline'] ?? "",
      source: json['source'] ?? "Unknown",
      snippet: json['summary'] ?? "",
      url: json['url'] ?? "",
      datetime: DateTime.fromMillisecondsSinceEpoch(json['datetime'] * 1000),
    );
  }
}
