import 'package:flutter/material.dart';

class PollsPage extends StatelessWidget {
  const PollsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polls'),
      ),
      body: const Center(
        child: Text('Polls Screen Placeholder'),
      ),
    );
  }
}
