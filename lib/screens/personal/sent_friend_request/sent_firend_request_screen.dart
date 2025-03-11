import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:musik/common/config.dart';

class SentFriendRequestsScreen extends StatefulWidget {
  @override
  _SentFriendRequestsScreenState createState() => _SentFriendRequestsScreenState();
}

class _SentFriendRequestsScreenState extends State<SentFriendRequestsScreen> {
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> sentRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSentFriendRequests();
  }

  Future<void> _fetchSentFriendRequests() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      _showMessage('Authentication token not found');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/list_sent_friend_requests'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        sentRequests =
            data
                .map(
                  (request) => {
                    'request_id': request['request_id'],
                    'recipient_id': request['recipient_id'],
                    'recipient_name': request['recipient_name'],
                    'recipient_email': request['recipient_email'],
                  },
                )
                .toList();
        isLoading = false;
      });
    } else {
      _showMessage('Failed to load sent friend requests');
    }
  }

  Future<void> _cancelSentRequest(int requestId) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      _showMessage('Authentication token not found');
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_friend_request'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'request_id': requestId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        sentRequests.removeWhere((request) => request['request_id'] == requestId);
      });
      _showMessage('Friend request cancelled');
    } else {
      _showMessage('Failed to cancel friend request');
    }
  }

  void _showMessage(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.top,
      backgroundColor: Colors.black54,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lời mời kết bạn đã gửi'),
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
                  itemCount: sentRequests.length,
                  itemBuilder: (context, index) {
                    final request = sentRequests[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.teal,
                          child: Text(request['recipient_name'][0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(request['recipient_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(request['recipient_email']),
                        trailing: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            _cancelSentRequest(request['request_id']);
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
