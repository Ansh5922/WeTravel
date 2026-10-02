import 'package:flutter/material.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
      ),
      body: const Center(
        child: Text('Trips Screen Placeholder'),
      ),
    );
  }
}
