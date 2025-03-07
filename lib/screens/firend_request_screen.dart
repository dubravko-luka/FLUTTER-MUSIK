import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatelessWidget {
  final List<Map<String, String>> friendRequests = [
    {'name': 'Minh Phương', 'email': 'minhphuong@example.com'},
    {'name': 'Tuấn Anh', 'email': 'tuananh@example.com'},
    {'name': 'Lan Hương', 'email': 'lanhuong@example.com'},
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
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.teal,
                  child: Text(friendRequests[index]['name']![0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(friendRequests[index]['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(friendRequests[index]['email']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // Add accept functionality here
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // Add decline functionality here
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
