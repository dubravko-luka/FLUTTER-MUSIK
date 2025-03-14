import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/common/config.dart';
import 'package:musik/screens/(common)/messaging_screen.dart';
import 'package:musik/services/auth_service.dart';

class SentMessagesScreen extends StatefulWidget {
  @override
  _SentMessagesScreenState createState() => _SentMessagesScreenState();
}

class _SentMessagesScreenState extends State<SentMessagesScreen> {
  final _storage = FlutterSecureStorage();
  final AuthService _authService = AuthService();
  List<dynamic> _sentMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSentMessages();
  }

  Future<void> _fetchSentMessages() async {
    String? token = await _storage.read(key: 'authToken');
    if (token == null) {
      // Handle absence of token, e.g., redirect to login
      return;
    }

    final response = await http.get(Uri.parse('${baseUrl}/sent_messages'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      setState(() {
        _sentMessages = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load sent messages');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages'), backgroundColor: Colors.teal, centerTitle: true, elevation: 1),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _sentMessages.length,
                  itemBuilder: (context, index) {
                    final message = _sentMessages[index];
                    final avatar = _authService.generateAvatarUrl(message['is_me'] ? message['recipient_id'] : message['sender_id']);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MessagingScreen(
                                  recipientId: message['is_me'] ? message['recipient_id'] : message['sender_id'],
                                  connectId: message['is_me'] ? message['sender_id'] : message['recipient_id'],
                                  recipientName: message['name'],
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 2.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                GestureDetector(child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(avatar))),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        child: Text(message['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
