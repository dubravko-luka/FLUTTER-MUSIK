import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:musik/common/config.dart';
import 'package:musik/services/auth_service.dart';
import 'package:musik/widgets/friend_options_sheet.dart';
import 'package:musik/widgets/success_popup.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final storage = FlutterSecureStorage();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/list_friend_requests'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        friendRequests =
            data
                .map(
                  (request) => {
                    'request_id': request['request_id'],
                    'requester_id': request['requester_id'],
                    'requester_name': request['requester_name'],
                    'requester_email': request['requester_email'],
                  },
                )
                .toList();
        isLoading = false;
      });
    } else {
      return;
    }
  }

  Future<void> _acceptFriendRequest(int requestId) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/accept_friend_request'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'request_id': requestId}),
    );

    if (response.statusCode == 201) {
      setState(() {
        friendRequests.removeWhere(
          (request) => request['request_id'] == requestId,
        );
      });
      SuccessPopup(
        message: 'Chấp nhận thành công',
        outerContext: context,
      ).show();
    } else {
      _fetchFriendRequests();
      SuccessPopup(
        message: 'Chấp nhận thất bại',
        outerContext: context,
      ).show(success: false);
    }
  }

  Future<void> _declineFriendRequest(int requestId) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/decline_friend_request'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'request_id': requestId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        friendRequests.removeWhere(
          (request) => request['request_id'] == requestId,
        );
      });
      SuccessPopup(message: 'Từ chối thành công', outerContext: context).show();
    } else {
      _fetchFriendRequests();
      SuccessPopup(
        message: 'Từ chối thất bại',
        outerContext: context,
      ).show(success: false);
    }
  }

  void _showBottomSheet(BuildContext context, request) {
    final avatar = _authService.generateAvatarUrl(request['requester_id']);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => FriendOptionsSheet(
            name: request['requester_name'],
            avatarUrl: avatar,
            profileUserId: request['requester_id'],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lời mời kết bạn'),
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
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendRequests[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => _showBottomSheet(context, request),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              _authService.generateAvatarUrl(
                                request['requester_id'],
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          request['requester_name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(request['requester_email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _acceptFriendRequest(request['request_id']);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _declineFriendRequest(request['request_id']);
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
