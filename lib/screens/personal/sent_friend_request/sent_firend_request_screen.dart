import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:musik/common/config.dart';
import 'package:musik/widgets/friend_options_sheet.dart';
import 'package:musik/widgets/success_popup.dart';

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

  void _showBottomSheet(BuildContext context, request) {
    final avatar = '$baseUrl/get_avatar/${request['recipient_id']}';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FriendOptionsSheet(name: request['recipient_name'], avatarUrl: avatar, profileUserId: request['recipient_id']),
    );
  }

  Future<void> _fetchSentFriendRequests() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
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
      return;
    }
  }

  Future<void> _cancelSentRequest(int requestId) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
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
      SuccessPopup(message: 'Hủy lời mời kết bạn thành công', outerContext: context).show();
    } else {
      SuccessPopup(message: 'Vui lòng thử lại', outerContext: context).show(success: false);
    }
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
                        leading: GestureDetector(
                          onTap: () => _showBottomSheet(context, request),
                          child: CircleAvatar(radius: 30, backgroundImage: NetworkImage('$baseUrl/get_avatar/${request['recipient_id']}')),
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
