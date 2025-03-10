import 'package:flutter/material.dart';
import 'package:musik/screens/personal/friend_request/firend_request_screen.dart';
import 'package:musik/screens/personal/help_support/help_support_screen.dart';
import 'package:musik/screens/personal/sent_friend_request/sent_firend_request_screen.dart';
import 'package:musik/screens/personal/setting/settings.dart';
import 'friend/friends_screen.dart';
import 'person_info/personal_info_screen.dart';
import 'upload_music/upload_music_screen.dart';

class ProfileScreen extends StatelessWidget {
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
                  child: Icon(Icons.person, size: 60, color: Colors.teal),
                ),
              ),
              SizedBox(height: 24),
              ..._buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'title': 'Thông tin cá nhân', 'screen': PersonalInfoScreen()},
      {'title': 'Tải nhạc lên', 'screen': UploadMusicScreen()},
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
