import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock.dart';
import '../models/candle.dart';
import '../services/stock_api_service.dart';
import 'dart:math' show min, max;

class StockDataScreen extends StatefulWidget {
  @override
  _StockDataScreenState createState() => _StockDataScreenState();
}

class _StockDataScreenState extends State<StockDataScreen> {
  final StockApiService _stockService = StockApiService();
  Stock? _stock;
  List<Candle>? _candleData;
  bool _isLoading = false;
  String _symbol = 'AAPL'; // Default symbol

  final List<String> _stockSymbols = [
    'AAPL',  // Apple
    'AMZN',  // Amazon
    'MSFT',  // Microsoft
    'GOOGL', // Google
    'META',  // Meta (Facebook)
    'TSLA',  // Tesla
    'NVDA',  // NVIDIA
    'AMD',   // AMD
    'NFLX',  // Netflix
    'UBER',   // Uber
    'Ebay',  // Ebay
    'BOFA',  // Bank of America 
  ];

  Map<String, List<Candle>> _allStockCandles = {};
  Map<String, Stock> _allStocks = {};

  @override
  void initState() {
    super.initState();
    _loadAllStockData();
  }

  Future<void> _loadAllStockData() async {
    setState(() => _isLoading = true);
    try {
      // Load data for all stocks
      for (String symbol in _stockSymbols) {
        try {
          final stock = await _stockService.getStockQuote(symbol);
          final candles = await _stockService.getStockCandles(symbol, 'D', 0, 0);
          setState(() {
            _allStocks[symbol] = stock;
            _allStockCandles[symbol] = candles;
            if (symbol == _symbol) {
              _stock = stock;
              _candleData = candles;
            }
          });
        } catch (e) {
          print('Error loading data for $symbol: $e');
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStockData() async {
    try {
      final stock = await _stockService.getStockQuote(_symbol);
      final candles = await _stockService.getStockCandles(_symbol, 'D', 0, 0);
      
      print('Loaded ${candles.length} candles for $_symbol'); // Debug print
      print('First candle: ${candles.firstOrNull}'); // Debug print
      
      setState(() {
        _stock = stock;
        _candleData = candles;
        _allStockCandles[_symbol] = candles;
      });
    } catch (e) {
      print('Error in _loadStockData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stock data: $e')),
      );
    }
  }

  // Add mini chart widget for sidebar
  Widget _buildMiniChart(String symbol) {
    final candles = _allStockCandles[symbol];
    if (candles == null || candles.isEmpty) return SizedBox(height: 30);

    return SizedBox(
      height: 30,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: candles.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.close,
                );
              }).toList(),
              isCurved: true,
              color: candles.first.close < candles.last.close 
                  ? Colors.green 
                  : Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // Modify the sidebar list item
  Widget _buildStockListItem(String symbol) {
    final stock = _allStocks[symbol];
    
    return InkWell(
      onTap: () {
        setState(() {
          _symbol = symbol;
          _stock = _allStocks[symbol];
          _candleData = _allStockCandles[symbol];
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _symbol == symbol 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontWeight: _symbol == symbol 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
                if (stock != null) ...[
                  Icon(
                    stock.percentChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: stock.percentChange >= 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ],
              ],
            ),
            if (stock != null) ...[
              Text(
                '${stock.percentChange >= 0 ? '+' : ''}${stock.percentChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: stock.percentChange >= 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
            SizedBox(height: 4),
            _buildMiniChart(symbol),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StockWatch'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStockData,
          ),
        ],
      ),
      body: Row(
        children: [
          // Stock List Sidebar
          Container(
            width: 150,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListView.builder(
              itemCount: _stockSymbols.length,
              itemBuilder: (context, index) => _buildStockListItem(_stockSymbols[index]),
            ),
          ),
          // Main Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _stock == null
                    ? Center(child: Text('No data available'))
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStockHeader(),
                            SizedBox(height: 24),
                            _buildPriceChart(),
                            SizedBox(height: 24),
                            _buildStockDetails(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stock!.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$${_stock!.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(width: 16),
            Text(
              '${_stock!.percentChange >= 0 ? '+' : ''}${_stock!.percentChange.toStringAsFixed(2)}%',
              style: TextStyle(
                color: _stock!.percentChange >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceChart() {
    print('Building chart with data: ${_candleData?.length} candles');
    if (_candleData == null || _candleData!.isEmpty || _stock == null) {
      return Container(
        height: 300,
        child: Center(child: Text('Loading chart data...')),
      );
    }

    // Create price movement data points
    final currentPrice = _stock!.price;
    final previousClose = _stock!.previousClose;
    final priceChange = currentPrice - previousClose;
    final color = priceChange >= 0 ? Colors.green : Colors.red;

    // Create a series of points to show price movement
    final List<FlSpot> spots = [
      FlSpot(0, previousClose), // Previous close
      FlSpot(1, (previousClose + currentPrice) / 2), // Midpoint
      FlSpot(2, currentPrice), // Current price
    ];

    final minY = min(previousClose, currentPrice) * 0.9995;
    final maxY = max(previousClose, currentPrice) * 1.0005;

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade800,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 55,
                interval: 0.5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final labels = ['Previous Close', '', 'Current'];
                  if (value >= 0 && value < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 2,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Open', '\$${_stock!.open.toStringAsFixed(2)}'),
            _buildDetailRow('High', '\$${_stock!.high.toStringAsFixed(2)}'),
            _buildDetailRow('Low', '\$${_stock!.low.toStringAsFixed(2)}'),
            _buildDetailRow('Previous Close', '\$${_stock!.previousClose.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
