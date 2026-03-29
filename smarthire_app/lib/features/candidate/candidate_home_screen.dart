import 'package:flutter/material.dart';

class CandidateHomeScreen extends StatelessWidget {
  const CandidateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Candidate Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}