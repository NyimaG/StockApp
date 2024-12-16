import 'package:flutter/material.dart';
import 'articleclass.dart';
import '../services/finnhubarticle_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[400]!,
          secondary: Colors.blue[300]!,
          surface: const Color(0xFF252525),
          surfaceContainerHighest: const Color(0xFF252525),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
      ),
      home: const Newsfeed(),
    );
  }
}

class Newsfeed extends StatefulWidget {
  const Newsfeed({super.key});

  @override
  State<Newsfeed> createState() => _NewsfeedState();
}

class _NewsfeedState extends State<Newsfeed> {
  final _symbolController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final String _apiKey = 'ctduit9r01qng9gfgi30ctduit9r01qng9gfgi3g';
  String _errorMessage = '';

  void _searchNews() {
    setState(() {
      _errorMessage = '';
    });

    String symbol = _symbolController.text.trim();
    String fromDate = _fromDateController.text.trim();
    String toDate = _toDateController.text.trim();

    if (symbol.isEmpty || fromDate.isEmpty || toDate.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    // Call fetchNews with the symbol and date range
    fetchNews(symbol, fromDate, toDate, _apiKey).then((articles) {
      // Navigate to the articles page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleListPage(articles: articles),
        ),
      );
    }).catchError((error) {
      setState(() {
        _errorMessage = 'Failed to load news: $error';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Welcome to your Newsfeed',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Look up stock related news for any company of your choice!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, /*fontWeight: FontWeight.bold*/
              ),
            ),
            SizedBox(height: 50),
            TextField(
              style: TextStyle(
                color: Colors.black, // Set the text color
                fontSize: 16, // Optional: Change the font size
              ),
              controller: _symbolController,
              decoration: InputDecoration(
                //labelText: 'Stock Symbol (e.g., AAPL)',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5)),
                //prefixIcon: Icon(Icons.person, color: Colors.black),
                hintText: "Stock Symbol (e.g., AAPL)",
                hintStyle: TextStyle(color: Colors.lightBlueAccent),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            TextField(
              style: TextStyle(
                color: Colors.black, // Set the text color
                fontSize: 16, // Optional: Change the font size
              ),
              controller: _fromDateController,
              decoration: InputDecoration(
                //labelText: 'From Date (YYYY-MM-DD)',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5)),
                //prefixIcon: Icon(Icons.person, color: Colors.black),
                hintText: "From Date (YYYY-MM-DD)",
                hintStyle: TextStyle(color: Colors.lightBlueAccent),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 40),
            TextField(
              style: TextStyle(
                color: Colors.black, // Set the text color
                fontSize: 16, // Optional: Change the font size
              ),
              controller: _toDateController,
              decoration: InputDecoration(
                //labelText: 'To Date (YYYY-MM-DD)',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5)),
                //prefixIcon: Icon(Icons.person, color: Colors.black),
                hintText: "To Date (YYYY-MM-DD)",
                hintStyle: TextStyle(color: Colors.lightBlueAccent),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _searchNews,
              child: Text('Search News'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ArticleListPage extends StatelessWidget {
  final List<Article> articles;

  ArticleListPage({required this.articles});

  // Function to launch the URL
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Articles'),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          if (articles.isEmpty) {
            Center(
              child: Text('No news available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  _launchUrl(
                    Uri.parse(articles[index].url ?? ""),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.network(
                        articles[index].image ??
                            'https://about.fb.com/wp-content/uploads/2024/02/Facebook-News-Update_US_AU_Header.jpg?w=1920',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    // Article Content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articles[index].headline ?? "No headline available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            articles[index].summary ?? "No summary available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
