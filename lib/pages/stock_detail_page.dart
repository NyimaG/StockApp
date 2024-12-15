import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/finnhub_service.dart';

class StockDetailPage extends StatefulWidget {
  final String symbol;
  final String name;

  const StockDetailPage({
    Key? key,
    required this.symbol,
    required this.name,
  }) : super(key: key);

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  final FinnhubService _finnhubService = FinnhubService();
  Map<String, dynamic>? _quoteData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuoteData();
  }

  Future<void> _loadQuoteData() async {
    try {
      final data = await _finnhubService.getQuote(widget.symbol);
      setState(() {
        _quoteData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading quote data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _quoteData == null
              ? Center(child: Text('Failed to load data'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 20),
                                _buildPriceChart(),
                                SizedBox(height: 20),
                                _buildQuoteDetails(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPriceChart() {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 5,
          minY: _quoteData!['l'] * 0.95,
          maxY: _quoteData!['h'] * 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, _quoteData!['pc']),
                FlSpot(1, _quoteData!['o']),
                FlSpot(2, _quoteData!['l']),
                FlSpot(3, _quoteData!['h']),
                FlSpot(4, _quoteData!['c']),
              ],
              isCurved: true,
              color: _quoteData!['d'] >= 0 ? Colors.green : Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteDetails() {
    return Column(
      children: [
        _buildDetailRow(
            'Current Price', '\$${_quoteData!['c'].toStringAsFixed(2)}'),
        _buildDetailRow('Change', '${_quoteData!['d'].toStringAsFixed(2)}'),
        _buildDetailRow('Change %', '${_quoteData!['dp'].toStringAsFixed(2)}%'),
        _buildDetailRow('High', '\$${_quoteData!['h'].toStringAsFixed(2)}'),
        _buildDetailRow('Low', '\$${_quoteData!['l'].toStringAsFixed(2)}'),
        _buildDetailRow('Open', '\$${_quoteData!['o'].toStringAsFixed(2)}'),
        _buildDetailRow(
            'Previous Close', '\$${_quoteData!['pc'].toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
