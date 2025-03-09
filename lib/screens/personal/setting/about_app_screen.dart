import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Information about the app goes here.'),
      ),
    );
  }
}
