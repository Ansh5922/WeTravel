import 'package:flutter/material.dart';

class PollsPage extends StatelessWidget {
  final String tripId;

  const PollsPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polls'),
      ),
      body: Center(
        child: Text('Polls ($tripId)'),
      ),
    );
  }
}
