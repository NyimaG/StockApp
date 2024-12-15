//import 'package:flutter/foundation.dart';

class Article {
  final String? headline;
  final String? source;
  final String? url;
  final String? summary;
  final String? image;
  final int? datetime;

  Article({
    this.headline,
    this.source,
    this.url,
    this.summary,
    this.image,
    this.datetime,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      headline: json['headline'] ?? 'No headline available',
      source: json['source'] ?? 'Unknown source',
      url: json['url'] ?? '',
      summary: json['summary'] ?? 'No summary available',
      image: json['image'], // image is optional
      datetime: json['datetime'] ?? '',
    );
  }
}
