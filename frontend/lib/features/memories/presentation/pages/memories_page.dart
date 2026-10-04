import 'package:flutter/material.dart';

class MemoriesPage extends StatelessWidget {
  final String tripId;

  const MemoriesPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: Center(
        child: Text('Memories ($tripId)'),
      ),
    );
  }
}
