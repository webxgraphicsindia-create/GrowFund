import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Logging out...', style: TextStyle(fontSize: 24)),
    );
  }
}
