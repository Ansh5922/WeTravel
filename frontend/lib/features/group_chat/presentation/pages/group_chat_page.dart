import 'package:flutter/material.dart';

class GroupChatPage extends StatelessWidget {
  final String tripId;

  const GroupChatPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
      ),
      body: Center(
        child: Text('Group Chat ($tripId)'),
      ),
    );
  }
}
