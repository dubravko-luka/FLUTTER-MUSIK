import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:musik/common/config.dart';
import 'package:musik/screens/(common)/personal_info_screen.dart';

class FriendOptionsSheet extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final int profileUserId;

  FriendOptionsSheet({
    required this.name,
    required this.avatarUrl,
    required this.profileUserId,
  });

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
        friendRequestDirection = data['friend_request_direction'];
      });
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
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                icon: Icon(Icons.account_circle, color: Colors.orange),
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
