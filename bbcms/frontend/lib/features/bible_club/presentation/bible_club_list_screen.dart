import 'package:flutter/material.dart';

class BibleClubListScreen extends StatelessWidget {
  const BibleClubListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Club Directory')),
      body: const Center(child: Text('Phase 2 — clubs list')),
    );
  }
}
