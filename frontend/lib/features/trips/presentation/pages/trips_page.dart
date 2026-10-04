import 'package:flutter/material.dart';
import '../../../trip_details/presentation/pages/trip_details_page.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TripDetailsPage(tripId: 'goa-weekend');
  }
}
