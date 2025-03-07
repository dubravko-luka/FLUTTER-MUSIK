import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  final List<Map<String, String>> friends = [
    {'name': 'Minh Phương', 'email': 'minhphuong@example.com'},
    {'name': 'Tuấn Anh', 'email': 'tuananh@example.com'},
    {'name': 'Lan Hương', 'email': 'lanhuong@example.com'},
    {'name': 'Trung Kiên', 'email': 'trungkien@example.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.teal,
                  child: Text(friends[index]['name']![0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(friends[index]['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(friends[index]['email']!),
                trailing: IconButton(
                  icon: Icon(Icons.message, color: Colors.teal),
                  onPressed: () {
                    // Add chat functionality here
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
