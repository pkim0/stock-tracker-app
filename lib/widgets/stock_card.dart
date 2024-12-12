import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String name;
  final String symbol;
  final double price;
  final double percentChange;

  const StockCard({
    required this.name,
    required this.symbol,
    required this.price,
    required this.percentChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text(symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(2)}%',
              style: TextStyle(
                color: percentChange >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to stock details screen
          Navigator.pushNamed(context, '/stock-data', arguments: symbol);
        },
      ),
    );
  }
}
