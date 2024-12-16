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
    double lowestPrice = _quoteData!['l'];
    double highestPrice = _quoteData!['h'];
    double priceRange = highestPrice - lowestPrice;
    
    double minY = lowestPrice - (priceRange * 0.2);
    double maxY = highestPrice + (priceRange * 0.2);
    
    double interval = (maxY - minY) / 5;  

    return Container(
      height: 350,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: interval,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 65,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '\$${value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40, 
                getTitlesWidget: (value, meta) {
                  String text = '';
                  switch (value.toInt()) {
                    case 0:
                      text = 'Prev';
                      break;
                    case 1:
                      text = 'Open';
                      break;
                    case 2:
                      text = 'Low';
                      break;
                    case 3:
                      text = 'High';
                      break;
                    case 4:
                      text = 'Current';
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 4,
          minY: minY,
          maxY: maxY,
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
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: barData.color ?? Colors.blue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: (_quoteData!['d'] >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
              ),
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
