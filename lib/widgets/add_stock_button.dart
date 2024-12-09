import 'package:flutter/material.dart';

class AddStockButton extends StatelessWidget {
  final VoidCallback onTap;

  AddStockButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
    );
  }
}
