import 'package:flutter/material.dart';
import 'stock_watchlist_screen.dart';
import 'stock_data_screen.dart';
import 'financial_news_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StockWatch'),
        centerTitle: true,
      ),
      body: GridView(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: [
          HomeButton(
            title: 'Stock Watchlist',
            icon: Icons.list_alt,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StockWatchlistScreen()),
            ),
          ),
          HomeButton(
            title: 'Stock Data',
            icon: Icons.bar_chart,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StockDataScreen()),
            ),
          ),
          HomeButton(
            title: 'Financial News',
            icon: Icons.newspaper,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FinancialNewsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  HomeButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
