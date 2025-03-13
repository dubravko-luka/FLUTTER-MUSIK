import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/screens/personal/friend_request/firend_request_screen.dart';
import 'package:musik/screens/personal/help_support/help_support_screen.dart';
import 'package:musik/screens/personal/sent_friend_request/sent_firend_request_screen.dart';
import 'package:musik/screens/personal/setting/settings.dart';
import 'package:musik/screens/personal/upload_music/upload_music_web_screen.dart';
import 'package:musik/screens/personal/friend/friends_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:musik/screens/personal/person_info/personal_info_screen.dart';
import 'package:musik/screens/personal/upload_music/upload_music_screen.dart';
import 'package:http/http.dart' as http;
import 'package:musik/common/config.dart';
import 'package:musik/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage();
  String? _avatarUrl;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final token = await storage.read(key: 'authToken');
    final userId = await storage.read(key: 'userId');

    if (token == null || userId == null) {
      print('Token or User ID not found');
      return;
    }

    _userId = int.tryParse(userId);
    setState(() {
      _avatarUrl = '${baseUrl}/get_avatar/$_userId';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child:
                        _avatarUrl == null
                            ? Icon(Icons.person, size: 60, color: Colors.teal)
                            : null,
                  ),
                ),
                SizedBox(height: 24),
                ..._buildMenuItems(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'title': 'Thông tin cá nhân', 'screen': PersonalInfoScreen()},
      {
        'title': 'Tải nhạc lên',
        'screen': kIsWeb ? UploadMusicWebScreen() : UploadMusicScreen(),
      },
      {'title': 'Bạn bè', 'screen': FriendsScreen()},
      {'title': 'Lời mời kết bạn', 'screen': FriendRequestsScreen()},
      {'title': 'Lời mời đã gửi', 'screen': SentFriendRequestsScreen()},
      {'title': 'Trợ giúp & hỗ trợ', 'screen': HelpSupportScreen()},
      {'title': 'Cài đặt', 'screen': SettingsScreen()},
    ];

    return menuItems.map((item) {
      return _buildMenuItem(
        item['title'] as String,
        context,
        item['screen'] as Widget,
      );
    }).toList();
  }

  Widget _buildMenuItem(String title, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
        ),
      ),
    );
  }
}
