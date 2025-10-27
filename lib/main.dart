import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Network',
      home: Scaffold(
        appBar: AppBar(title: const Text('Life Network')),
        body: const Center(
          child: Text('Welcome to Life Network App'),
        ),
      ),
    );
  }
}
