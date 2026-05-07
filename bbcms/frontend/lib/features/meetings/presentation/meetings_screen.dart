import 'package:flutter/material.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réunions')),
      body: const Center(child: Text('Phase 4 — meetings')),
    );
  }
}
