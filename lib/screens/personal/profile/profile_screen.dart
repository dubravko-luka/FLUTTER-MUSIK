import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/screens/personal/friend_request/firend_request_screen.dart';
import 'package:musik/screens/personal/help_support/help_support_screen.dart';
import 'package:musik/screens/personal/sent_friend_request/sent_firend_request_screen.dart';
import 'package:musik/screens/personal/setting/settings.dart';
import 'package:musik/screens/personal/friend/friends_screen.dart';
import 'package:musik/screens/personal/person_info/personal_info_screen.dart';
import 'package:musik/screens/personal/upload_music/upload_music_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1, // square tiles
            children: _buildMenuItems(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'title': 'Thông tin cá nhân', 'screen': PersonalInfoScreen(), 'icon': Icons.person},
      {'title': 'Tải nhạc lên', 'screen': UploadMusicScreen(), 'icon': Icons.cloud_upload},
      {'title': 'Bạn bè', 'screen': FriendsScreen(), 'icon': Icons.people},
      {'title': 'Lời mời kết bạn', 'screen': FriendRequestsScreen(), 'icon': Icons.person_add},
      {'title': 'Lời mời đã gửi', 'screen': SentFriendRequestsScreen(), 'icon': Icons.send},
      {'title': 'Trợ giúp & hỗ trợ', 'screen': HelpSupportScreen(), 'icon': Icons.help},
      {'title': 'Cài đặt', 'screen': SettingsScreen(), 'icon': Icons.settings},
    ];

    return menuItems.map((item) {
      return _buildMenuItem(item['title'] as String, context, item['screen'] as Widget, item['icon'] as IconData);
    }).toList();
  }

  Widget _buildMenuItem(String title, BuildContext context, Widget screen, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.teal),
              SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
