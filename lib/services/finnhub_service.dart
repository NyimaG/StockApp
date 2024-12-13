import 'dart:convert';
import 'package:http/http.dart' as http;

class FinnhubService {
  final String apiKey = 'ctbqgg1r01qvslqv5r20ctbqgg1r01qvslqv5r2g';
  final String baseUrl = 'https://finnhub.io/api/v1';

  Future<Map<String, dynamic>> getQuote(String symbol) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey'),
      headers: {'X-Finnhub-Token': apiKey},
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load quote');
  }

  Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    if (query.isEmpty) return [];

    try {
      final symbolResponse = await http.get(
        Uri.parse('$baseUrl/search?q=$query&exchange=US&token=$apiKey'),
        headers: {
          'X-Finnhub-Token': apiKey,
          'Accept': 'application/json',
        },
      );

      if (symbolResponse.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(symbolResponse.body);
        final List<dynamic> results = responseData['result'] ?? [];
        final searchQuery = query.toLowerCase();

        return List<Map<String, dynamic>>.from(results).where((stock) {
          if (stock['type']?.toString().isEmpty ?? true) return false;

          final symbol = stock['symbol'].toString();
          final description = stock['description'].toString().toLowerCase();
          final isCommonStock =
              stock['type'].toString().toLowerCase().contains('common stock');
          final isPrimaryListing = !symbol.contains('.');

          final matchesSymbol = symbol.toLowerCase().contains(searchQuery);
          final matchesDescription = description.contains(searchQuery);

          return isCommonStock &&
              isPrimaryListing &&
              (matchesSymbol || matchesDescription);
        }).toList()
          ..sort((a, b) {
            final aSymbol = a['symbol'].toString().toLowerCase();
            final bSymbol = b['symbol'].toString().toLowerCase();
            final aDesc = a['description'].toString().toLowerCase();
            final bDesc = b['description'].toString().toLowerCase();

            if (aDesc.startsWith(searchQuery)) return -1;
            if (bDesc.startsWith(searchQuery)) return 1;

            if (aSymbol == searchQuery) return -1;
            if (bSymbol == searchQuery) return 1;

            final aWords = aDesc.split(' ');
            final bWords = bDesc.split(' ');
            final aHasExactWord =
                aWords.any((word) => word.toLowerCase() == searchQuery);
            final bHasExactWord =
                bWords.any((word) => word.toLowerCase() == searchQuery);
            if (aHasExactWord && !bHasExactWord) return -1;
            if (!aHasExactWord && bHasExactWord) return 1;

            return aSymbol.length.compareTo(bSymbol.length);
          });
      }
      return [];
    } catch (e) {
      print('Error searching stocks: $e');
      return [];
    }
  }
}
