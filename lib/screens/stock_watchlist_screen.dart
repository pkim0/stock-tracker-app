import 'package:flutter/material.dart';
import '../widgets/stock_card.dart';
import '../widgets/add_stock_button.dart';
import '../services/stock_api_service.dart';
import '../models/stock.dart';

class StockWatchlistScreen extends StatefulWidget {
  @override
  _StockWatchlistScreenState createState() => _StockWatchlistScreenState();
}

class _StockWatchlistScreenState extends State<StockWatchlistScreen> {
  final StockApiService _stockService = StockApiService();
  List<Stock> watchlist = [];
  bool isLoading = true;

  // Default watchlist symbols
  final List<String> watchlistSymbols = ['AAPL', 'MSFT', 'TSLA'];

  @override
  void initState() {
    super.initState();
    _loadWatchlistData();
  }

  Future<void> _loadWatchlistData() async {
    setState(() => isLoading = true);
    try {
      final List<Stock> loadedStocks = [];
      for (String symbol in watchlistSymbols) {
        final stock = await _stockService.getStockQuote(symbol);
        loadedStocks.add(stock);
      }
      setState(() {
        watchlist = loadedStocks;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading watchlist: $e')),
      );
    }
  }

  Future<void> _addNewStock(String symbol) async {
    try {
      final stock = await _stockService.getStockQuote(symbol);
      setState(() {
        watchlist.add(stock);
        watchlistSymbols.add(symbol);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding stock: $e')),
      );
    }
  }

  void _showAddStockDialog() {
    String newSymbol = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Stock'),
        content: TextField(
          onChanged: (value) => newSymbol = value.toUpperCase(),
          decoration: InputDecoration(
            labelText: 'Stock Symbol',
            hintText: 'Enter stock symbol (e.g., AAPL)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newSymbol.isNotEmpty) {
                _addNewStock(newSymbol);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Watchlist'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadWatchlistData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWatchlistData,
              child: ListView.builder(
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  final stock = watchlist[index];
                  return InkWell(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Remove Stock'),
                          content: Text('Remove ${stock.symbol} from watchlist?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  watchlistSymbols.remove(stock.symbol);
                                  watchlist.removeAt(index);
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Remove', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: StockCard(
                      name: stock.name,
                      symbol: stock.symbol,
                      price: stock.price,
                      percentChange: stock.percentChange,
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: AddStockButton(
        onTap: _showAddStockDialog,
      ),
    );
  }
}
