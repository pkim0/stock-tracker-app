import 'package:flutter/material.dart';
import '../widgets/stock_card.dart';
import '../widgets/add_stock_button.dart';

class StockWatchlistScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [
    {"name": "Apple", "symbol": "AAPL", "price": 175.43},
    {"name": "Microsoft", "symbol": "MSFT", "price": 331.77},
    {"name": "Tesla", "symbol": "TSLA", "price": 648.12},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Watchlist')),
      body: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return StockCard(
            name: stock['name'],
            symbol: stock['symbol'],
            price: stock['price'],
          );
        },
      ),
      floatingActionButton: AddStockButton(
        onTap: () {
          // Implement stock addition logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add Stock feature is under development!')),
          );
        },
      ),
    );
  }
}
