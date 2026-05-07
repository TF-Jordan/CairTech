import 'package:flutter/material.dart';

class PublicationsScreen extends StatelessWidget {
  const PublicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publications')),
      body: const Center(child: Text('Phase 6 — daily verses & announcements')),
    );
  }
}
