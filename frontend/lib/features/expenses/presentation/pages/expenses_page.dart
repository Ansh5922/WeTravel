import 'package:flutter/material.dart';

class ExpensesPage extends StatelessWidget {
  final String tripId;

  const ExpensesPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Center(
        child: Text('Expenses ($tripId)'),
      ),
    );
  }
}
