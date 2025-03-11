import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:musik/common/config.dart';
import 'dart:convert';
import 'friend_options_sheet.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      _showMessage('Authentication token not found');
      return;
    }

    final response = await http.get(Uri.parse('$baseUrl/list_friends'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        friends = data.map((friend) => {'id': friend['id'], 'name': friend['name'], 'email': friend['email']}).toList();
        isLoading = false;
      });
    } else {
      _showMessage('Failed to load friends');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showOptionsBottomSheet(BuildContext context, Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return FriendOptionsSheet(
          name: friend['name'],
          avatarUrl: "https://via.placeholder.com/150", // Use an actual image URL
          profileUserId: friend['id'],
          onFriendRemoved: _fetchFriends, // Pass the callback
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bạn bè'),
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
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.teal,
                          child: Text(friend['name'][0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(friend['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(friend['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.teal),
                          onPressed: () {
                            _showOptionsBottomSheet(context, friend);
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
