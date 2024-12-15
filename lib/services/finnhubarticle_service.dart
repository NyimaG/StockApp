import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;
import '../articleclass.dart';

Future<List<Article>> fetchNews(
    String symbol, String fromDate, String toDate, String apiKey) async {
  //final String apiKey ='ctduit9r01qng9gfgi30ctduit9r01qng9gfgi3g'; // Replace with your News API key
  //final String symbol = 'GOOG';

  final String url =
      'https://finnhub.io/api/v1/company-news?symbol=$symbol&from=$fromDate&to=$toDate&token=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body); // Decode the response to a List
      return data.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception(
          'Failed to load news: ${response.statusCode} Invalid input; Check format');
    }
  } catch (e) {
    throw Exception('Failed to load news: $e');
  }
}
