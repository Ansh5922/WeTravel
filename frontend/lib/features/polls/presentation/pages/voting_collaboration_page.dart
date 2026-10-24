import 'package:flutter/material.dart';
import 'polls_page.dart';

/// Dynamic Voting & Collaboration Page connected to PollBloc
class VotingCollaborationPage extends StatelessWidget {
  final String tripId;

  const VotingCollaborationPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return PollsPage(tripId: tripId);
  }
}
