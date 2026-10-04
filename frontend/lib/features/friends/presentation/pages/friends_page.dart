import 'package:flutter/material.dart';
import 'package:frontend/features/inbox/presentation/pages/inbox_page.dart';

/// The Friends/Inbox tab inside the main authenticated shell.
/// Displays user invitations and friend requests matching the WeTravel design.
class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InboxPage();
  }
}
