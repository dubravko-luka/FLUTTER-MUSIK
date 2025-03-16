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
      SuccessPopup(message: 'Xóa bạn thành công', outerContext: context).show();
    } else {
      SuccessPopup(
        message: 'Không thể xóa nhạc',
        outerContext: context,
      ).show(success: false);
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
      SuccessPopup(
        message: 'Gửi lời mời kết bạn thành công',
        outerContext: context,
      ).show();
    } else {
      SuccessPopup(
        message: 'Gửi lời mời kết bạn thất bại',
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
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isOwnProfile) ...[
                if (!isFriend && !isFriendRequest)
                  IconButton(
                    onPressed: _sendFriendRequest,
                    icon: Icon(Icons.person_add, color: Colors.orange),
                    tooltip: 'Add Friend',
                    iconSize: 36,
                  ),
                if (!isFriend && isFriendRequest) ...[
                  if (friendRequestDirection == "sent")
                    IconButton(
                      onPressed: _cancelFriendRequest,
                      icon: Icon(Icons.cancel, color: Colors.orange),
                      tooltip: 'Cancel Request',
                      iconSize: 36,
                    ),
                  if (friendRequestDirection == "received") ...[
                    IconButton(
                      onPressed: _acceptFriendRequest,
                      icon: Icon(Icons.check, color: Colors.orange),
                      tooltip: 'Accept Request',
                      iconSize: 36,
                    ),
                    IconButton(
                      onPressed: _cancelFriendRequest,
                      icon: Icon(Icons.close, color: Colors.red),
                      tooltip: 'Decline Request',
                      iconSize: 36,
                    ),
                  ],
                ],
                if (isFriend)
                  IconButton(
                    onPressed: _removeFriend,
                    icon: Icon(Icons.person_remove, color: Colors.red),
                    tooltip: 'Remove Friend',
                    iconSize: 36,
                  ),
                if (isFriend)
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
                    icon: Icon(Icons.message, color: Colors.orange),
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
