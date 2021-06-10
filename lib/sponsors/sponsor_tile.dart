import 'package:flutter/material.dart';

class SponsorTile extends StatelessWidget {
  SponsorTile({required this.name, required this.amount});

  final String name;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(name, style: TextStyle(fontSize: 20)),
      subtitle: Text('${amount.toStringAsFixed(2)}€ / km'),
    ));
  }
}
