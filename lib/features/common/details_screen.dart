import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final String detail;

  const DetailsScreen({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: Center(
        child: Text(detail),
      ),
    );
  }
}