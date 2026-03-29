import 'package:flutter/material.dart';

class CompanyHomeScreen extends StatelessWidget {
  const CompanyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Company Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}