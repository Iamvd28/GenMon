import 'package:flutter/material.dart';

class CoinBalanceWidget extends StatelessWidget {
  final int coins;
  const CoinBalanceWidget({Key? key, required this.coins}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.monetization_on, color: Colors.amber),
        SizedBox(width: 4),
        Text('$coins', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ],
    );
  }
} 