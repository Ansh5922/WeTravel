import 'package:flutter/material.dart';

class ItineraryPage extends StatelessWidget {
  final String tripId;

  const ItineraryPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
      ),
      body: Center(
        child: Text('Itinerary ($tripId)'),
      ),
    );
  }
}
