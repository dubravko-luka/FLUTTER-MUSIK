import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:musik/common/config.dart';

class FriendOptionsSheet extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final int profileUserId;

  FriendOptionsSheet({required this.name, required this.avatarUrl, required this.profileUserId});

  @override
  _FriendOptionsSheetState createState() => _FriendOptionsSheetState();
}

class _FriendOptionsSheetState extends State<FriendOptionsSheet> {
  bool isOwnProfile = false;
  bool isFriend = false;
  bool isFriendRequest = false;
  String? friendRequestDirection;
  int? friendRequestId;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getProfileInfo();
  }

  Future<void> _getProfileInfo() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.get(Uri.parse('$baseUrl/get_user_profile/${widget.profileUserId}'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isOwnProfile = data['my_profile'];
        isFriend = data['is_friend'];
        isFriendRequest = data['is_friend_request'];
        friendRequestId = data['friend_request_id'];
        friendRequestDirection = data['friend_request_direction'];
      });
    }
  }

  Future<void> _sendFriendRequest() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/send_friend_request'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'recipient_id': widget.profileUserId}),
    );

    if (response.statusCode == 201) {
      _getProfileInfo();
    }
  }

  Future<void> _cancelFriendRequest() async {
    final token = await storage.read(key: 'authToken');
    if (token == null || friendRequestId == null) {
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_friend_request'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'request_id': friendRequestId}),
    );

    if (response.statusCode == 200) {
      _getProfileInfo();
    }
  }

  Future<void> _removeFriend() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_friend'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'friend_id': widget.profileUserId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isFriend = false;
      });
      Navigator.pop(context);
      _showMessage('Friend deleted');
    } else {
      _showMessage('Failed to delete friend');
    }
  }

  Future<void> _acceptFriendRequest() async {
    final token = await storage.read(key: 'authToken');
    if (token == null || friendRequestId == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/accept_friend_request'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'request_id': friendRequestId}),
    );

    if (response.statusCode == 201) {
      _getProfileInfo();
      _showMessage('Friend request accepted');
    } else {
      _showMessage('Failed to accept friend request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(widget.avatarUrl)),
          SizedBox(height: 12),
          Text(widget.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isOwnProfile) ...[
                if (!isFriend && !isFriendRequest)
                  IconButton(onPressed: _sendFriendRequest, icon: Icon(Icons.person_add, color: Colors.teal), tooltip: 'Add Friend', iconSize: 36),
                if (!isFriend && isFriendRequest) ...[
                  if (friendRequestDirection == "sent")
                    IconButton(
                      onPressed: _cancelFriendRequest,
                      icon: Icon(Icons.cancel, color: Colors.teal),
                      tooltip: 'Cancel Request',
                      iconSize: 36,
                    ),
                  if (friendRequestDirection == "received") ...[
                    IconButton(onPressed: _acceptFriendRequest, icon: Icon(Icons.check, color: Colors.teal), tooltip: 'Accept Request', iconSize: 36),
                    IconButton(onPressed: _cancelFriendRequest, icon: Icon(Icons.close, color: Colors.red), tooltip: 'Decline Request', iconSize: 36),
                  ],
                ],
                if (isFriend)
                  IconButton(onPressed: _removeFriend, icon: Icon(Icons.person_remove, color: Colors.teal), tooltip: 'Remove Friend', iconSize: 36),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Implement Send Message logic
                  },
                  icon: Icon(Icons.message, color: Colors.teal),
                  tooltip: 'Send Message',
                  iconSize: 36,
                ),
              ],
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement View Profile logic
                },
                icon: Icon(Icons.account_circle, color: Colors.teal),
                tooltip: 'View Profile',
                iconSize: 36,
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
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
}
