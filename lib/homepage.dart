import 'package:flutter/material.dart';
import 'package:stockapp/newsfeed.dart';
//import 'package:stockapp/newsfeed.dart';
import 'package:stockapp/stockcharts.dart';
//import 'package:stockapp/stockcharts.dart';
//import 'package:stockapp/stocksearch.dart';
import 'pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';
import 'services/finnhub_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock App',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[400]!,
          secondary: Colors.blue[300]!,
          surface: const Color(0xFF252525),
          surfaceContainerHighest: const Color(0xFF252525),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardTheme: CardTheme(
          elevation: 2,
          color: const Color(0xFF252525),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const StockHomePage(),
    );
  }
}

class StockHomePage extends StatefulWidget {
  const StockHomePage({super.key});

  @override
  State<StockHomePage> createState() => _StockHomePageState();
}

class _StockHomePageState extends State<StockHomePage> {
  int _selectedIndex = 0;
  String? username;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _favorites = [];
  final FinnhubService _finnhubService = FinnhubService();
  Timer? _priceUpdateTimer;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    loadFavorites();
    _startPriceUpdates();
  }

  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> _loadUsername() async {
    String? savedUsername = await getUsername();
    setState(() {
      username = savedUsername;
    });
  }

  void _addToFavorites(Map<String, dynamic> stock) async {
    print('Adding stock: ${stock['symbol']} - ${stock['description']}');
    if (!mounted) return;

    try {
      final priceData = await _finnhubService.getQuote(stock['symbol']);

      setState(() {
        if (!_favorites.any((item) => item['symbol'] == stock['symbol'])) {
          _favorites.add({
            'symbol': stock['symbol'],
            'name': stock['description'],
            'price': priceData['c'].toStringAsFixed(2),
            'change':
                '${(((priceData['c'] - priceData['pc']) / priceData['pc']) * 100).toStringAsFixed(2)}%',
            'color': Color((Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0),
          });
        }
      });
    } catch (e) {
      print('Error fetching stock price: $e');
      setState(() {
        if (!_favorites.any((item) => item['symbol'] == stock['symbol'])) {
          _favorites.add({
            'symbol': stock['symbol'],
            'name': stock['description'],
            'price': '0.00',
            'change': '0.00%',
            'color': Color((Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0),
          });
        }
      });
    }

    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }

    saveFavorites();
  }

  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updatePrices();
    });
  }

  Future<void> _updatePrices() async {
    if (_favorites.isEmpty) return;

    for (var stock in _favorites) {
      {
        final priceData = await _finnhubService.getQuote(stock['symbol']);
        if (!mounted) return;

        setState(() {
          stock['price'] = priceData['c'].toStringAsFixed(2);
          stock['change'] =
              '${(((priceData['c'] - priceData['pc']) / priceData['pc']) * 100).toStringAsFixed(2)}%';
        });
      }
    }
  }

  Future<void> saveFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'favorites': _favorites
            .map((f) => {
                  'symbol': f['symbol'],
                  'name': f['name'],
                  'color': f['color'].value,
                })
            .toList(),
      });
    }
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('favorites')) {
        setState(() {
          _favorites = List<Map<String, dynamic>>.from(
            doc.data()!['favorites'].map((f) => {
                  'symbol': f['symbol'],
                  'name': f['name'],
                  'price': '0.00',
                  'change': '0.00%',
                  'color': Color(f['color']),
                }),
          );
        });
        _updatePrices();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: <Widget>[
                _buildHomeContent(),
                SearchPage(
                  onStockSelected: (stock) {
                    _addToFavorites(stock);
                  },
                ),
                StockCharts(),
                Newsfeed(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 10,
        height: 60,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search_sharp),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Charts',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            selectedIcon: Icon(Icons.newspaper_sharp),
            label: 'News',
          ),
        ],
      ),
    );
  }

  //@override
  //Widget build(BuildContext context) {
  Widget _buildHomeContent() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome, $username',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      onStockSelected: _addToFavorites,
                    ),
                  ),
                );
              },
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Search stocks...',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Favorites',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final stock = _favorites[index];
                final isPositiveChange = stock['change'].startsWith('+');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    height: 80,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: stock['color']?.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            stock['symbol'][0],
                            style: TextStyle(
                              color: stock['color'],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        stock['symbol'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        stock['name'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${stock['price']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (stock['change'].startsWith('-')
                                          ? Colors.red
                                          : Colors.green)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  stock['change'],
                                  style: TextStyle(
                                    color: stock['change'].startsWith('-')
                                        ? Colors.red[400]
                                        : Colors.green[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.grey[400], size: 20),
                            onPressed: () {
                              setState(() {
                                _favorites.removeAt(index);
                              });

                              saveFavorites();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
