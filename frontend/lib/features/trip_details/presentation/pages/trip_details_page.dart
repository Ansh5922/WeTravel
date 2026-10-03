import 'package:flutter/material.dart';

class TripDetailsPage extends StatelessWidget {
  final String tripId;

  const TripDetailsPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: Center(
        child: Text('Trip Details ($tripId)'),
      ),
    );
  }
}
