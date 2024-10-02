import 'package:flutter/material.dart';

import 'common/details_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DetailsScreen(detail: "Profile Details")),
            );
          },
          child: const Text('Go to Details'),
        ),
      ),
    );
  }
}