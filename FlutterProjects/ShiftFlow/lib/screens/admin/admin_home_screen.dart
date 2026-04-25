import 'package:flutter/material.dart';

import '../employee/history_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryScreen(ownerId: null, isAdmin: true);
  }
}
