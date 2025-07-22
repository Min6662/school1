import 'package:flutter/material.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Table'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text('Time Table screen is empty.'),
      ),
    );
  }
}
