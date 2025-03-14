import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/common/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessagingScreen extends StatefulWidget {
  final int recipientId;
  final int connectId;
  final String recipientName;

  MessagingScreen({required this.recipientId, required this.connectId, required this.recipientName});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _storage = FlutterSecureStorage();
  final _controller = TextEditingController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  IO.Socket? socket;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initializeSocket();
    _getMessages();
  }

  @override
  void dispose() {
    _isMounted = false;
    socket?.disconnect();
    super.dispose();
  }

  void _initializeSocket() {
    socket = IO.io('${baseUrl}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'user_id': widget.connectId.toString()},
    });

    socket?.connect();

    socket?.on('connect', (_) {
      if (_isMounted) {
        print('Connected');
        // Any other init actions
      }
    });

    socket?.on('new_message', (data) {
      if (_isMounted) {
        _getMessages();
        print('New message received: ${data['content']}');
      }
    });

    socket?.on('disconnect', (_) {
      if (_isMounted) {
        print('Disconnected');
      }
    });
  }

  Future<void> _getMessages() async {
    String? token = await _storage.read(key: 'authToken');
    if (token == null || !_isMounted) {
      return;
    }

    final response = await http.get(Uri.parse('${baseUrl}/messages/${widget.recipientId}'), headers: {'Authorization': token});

    if (_isMounted) {
      if (response.statusCode == 200) {
        setState(() {
          _messages = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load messages');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    String? token = await _storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    String content = _controller.text.trim();

    if (content.isEmpty) {
      return;
    }

    final response = await http.post(
      Uri.parse('${baseUrl}/send_message'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: json.encode({'recipient_id': widget.recipientId, 'content': content}),
    );

    if (response.statusCode == 201) {
      _controller.clear();
      _getMessages(); // Optionally refresh or rely on socket update
    } else {
      print('Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipientName), backgroundColor: Colors.teal, centerTitle: true, elevation: 1),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        bool isMe = message['is_me'];

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.teal.shade300 : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                                bottomLeft: isMe ? Radius.circular(15.0) : Radius.circular(0),
                                bottomRight: isMe ? Radius.circular(0) : Radius.circular(15.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(message['content'], style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                                const SizedBox(height: 5),
                                Text('at ${message['created_at']}', style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
