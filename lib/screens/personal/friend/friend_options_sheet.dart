import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:musik/common/config.dart';
import 'package:musik/screens/(common)/messaging_screen.dart';
import 'package:musik/screens/(common)/personal_info_screen.dart';
import 'package:musik/widgets/success_popup.dart';

class FriendOptionsSheet extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final int profileUserId;
  final VoidCallback onFriendRemoved; // Added callback

  FriendOptionsSheet({
    required this.name,
    required this.avatarUrl,
    required this.profileUserId,
    required this.onFriendRemoved, // Initialize callback
  });

  @override
  _FriendOptionsSheetState createState() => _FriendOptionsSheetState();
}

class _FriendOptionsSheetState extends State<FriendOptionsSheet> {
  bool isOwnProfile = false;
  bool isFriend = false;
  bool isFriendRequest = false;
  int? friendRequestId;
  final storage = FlutterSecureStorage();
  int _myId = 0;

  @override
  void initState() {
    super.initState();
    _getProfileInfo();
  }

  Future<void> _getProfileInfo() async {
    final myId = await storage.read(key: 'userId');
    if (myId != null) {
      _myId = int.parse(myId);
    }

    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_user_profile/${widget.profileUserId}'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isOwnProfile = data['my_profile'];
        isFriend = data['is_friend'];
        isFriendRequest = data['is_friend_request'];
        friendRequestId = data['friend_request_id'];
      });
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
      widget.onFriendRemoved(); // Call the callback
      Navigator.pop(context);
      SuccessPopup(message: 'Xóa thành công', outerContext: context).show();
    } else {
      SuccessPopup(
        message: 'Xóa thất bại',
        outerContext: context,
      ).show(success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(widget.avatarUrl),
          ),
          SizedBox(height: 12),
          Text(
            widget.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isOwnProfile) ...[
                if (isFriend)
                  IconButton(
                    onPressed: _removeFriend,
                    icon: Icon(Icons.person_remove, color: Colors.teal),
                    tooltip: 'Remove Friend',
                    iconSize: 36,
                  ),
                IconButton(
                  onPressed: () {
                    print(widget.profileUserId);
                    print(_myId);
                    print(widget.name);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MessagingScreen(
                              recipientId: widget.profileUserId,
                              connectId: _myId,
                              recipientName: widget.name,
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.message, color: Colors.teal),
                  tooltip: 'Send Message',
                  iconSize: 36,
                ),
              ],
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PersonalInfoScreen(
                            name: widget.name,
                            avatarUrl: widget.avatarUrl,
                            profileUserId: widget.profileUserId,
                          ),
                    ),
                  );
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
}
