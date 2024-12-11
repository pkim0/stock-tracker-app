import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock.dart';
import '../models/candle.dart';
import '../services/stock_api_service.dart';

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
    'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'META',
    'TSLA', 'NVDA', 'JPM', 'V', 'WMT',
    'PG', 'JNJ', 'UNH', 'HD', 'BAC',
    'DIS', 'NFLX', 'INTC', 'VZ', 'KO',
    'PEP', 'CSCO', 'ADBE', 'CRM', 'CMCSA',
    'NKE', 'MCD', 'PYPL', 'TMO', 'ACN',
    'COST', 'ABT', 'DHR', 'XOM', 'CVX'
  ];

  Map<String, List<Candle>> _allStockCandles = {};

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final to = now.millisecondsSinceEpoch ~/ 1000;
      final from = now.subtract(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000;

      final stock = await _stockService.getStockQuote(_symbol);
      final candles = await _stockService.getStockCandles(_symbol, 'D', from, to);
      
      setState(() {
        _stock = stock;
        _candleData = candles;
        _allStockCandles[_symbol] = candles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
    return InkWell(
      onTap: () {
        setState(() {
          _symbol = symbol;
        });
        _loadStockData();
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
            Text(
              symbol,
              style: TextStyle(
                fontWeight: _symbol == symbol 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
            ),
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
        title: Text('Stock Data'),
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
    if (_candleData == null || _candleData!.isEmpty) {
      return Container(
        height: 300,
        child: Center(child: Text('No chart data available')),
      );
    }

    final minY = _candleData!.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    final maxY = _candleData!.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    final priceChange = _candleData!.last.close - _candleData!.first.close;
    final color = priceChange >= 0 ? Colors.green : Colors.red;

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
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
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey,
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
                interval: 5,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= _candleData!.length) return Text('');
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    (_candleData![value.toInt()].timestamp * 1000).toInt()
                  );
                  return Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (_candleData!.length - 1).toDouble(),
          minY: minY * 0.999,
          maxY: maxY * 1.001,
          lineBarsData: [
            LineChartBarData(
              spots: _candleData!.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.close,
                );
              }).toList(),
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    (_candleData![barSpot.x.toInt()].timestamp * 1000).toInt()
                  );
                  return LineTooltipItem(
                    '${date.month}/${date.day}\n\$${barSpot.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
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
