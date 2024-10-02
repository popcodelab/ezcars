import 'package:flutter/material.dart';

import 'common/details_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DetailsScreen(detail: "Settings Details")),
            );
          },
          child: const Text('Go to Details'),
        ),
      ),
    );
  }
}