import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/screens/personal/friend_request/firend_request_screen.dart';
import 'package:musik/screens/personal/help_support/help_support_screen.dart';
import 'package:musik/screens/personal/sent_friend_request/sent_firend_request_screen.dart';
import 'package:musik/screens/personal/setting/settings.dart';
import 'package:musik/screens/personal/friend/friends_screen.dart';
import 'package:musik/screens/personal/person_info/personal_info_screen.dart';
import 'package:musik/screens/personal/upload_music/upload_music_screen.dart';
import 'package:musik/screens/(common)/sent_messages_screen.dart';
import 'package:musik/screens/library/album_saved/album_screen.dart';
import 'package:musik/screens/library/liked_music/my_liked_screen.dart';
import 'package:musik/screens/library/my_music/my_music_screen.dart';

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
          image: DecorationImage(
            image: AssetImage('assets/background.png'), // Path to your background image
            fit: BoxFit.cover, // Cover the whole screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildMenuItem('Thông tin cá nhân', context, PersonalInfoScreen(), Icons.person, fullWidth: true)),
                    SliverToBoxAdapter(child: SizedBox(height: 30)),
                    SliverGrid.count(
                      crossAxisCount: 2, // 2 items per row
                      crossAxisSpacing: 2, // Spacing b etween items
                      mainAxisSpacing: 2, // Spacing between items
                      childAspectRatio: 3, // Wider aspect ratio
                      children: [..._buildMenuItemsFriends(context)],
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 30)),
                    SliverGrid.count(
                      crossAxisCount: 2, // 2 items per row
                      crossAxisSpacing: 2, // Spacing b etween items
                      mainAxisSpacing: 2, // Spacing between items
                      childAspectRatio: 3, // Wider aspect ratio
                      children: [..._buildMenuItemsAlbum(context)],
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 30)),
                    SliverList(delegate: SliverChildListDelegate(_buildMenuItemsSettings(context))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItemsFriends(BuildContext context) {
    final menuItems = [
      {'title': 'Tải nhạc lên', 'screen': UploadMusicScreen(), 'icon': Icons.cloud_upload},
      {'title': 'Bạn bè', 'screen': FriendsScreen(), 'icon': Icons.people},
      {'title': 'Lời mời kết bạn', 'screen': FriendRequestsScreen(), 'icon': Icons.person_add},
      {'title': 'Lời mời đã gửi', 'screen': SentFriendRequestsScreen(), 'icon': Icons.send},
    ];

    return menuItems.map((item) {
      return _buildMenuItem(item['title'] as String, context, item['screen'] as Widget, item['icon'] as IconData);
    }).toList();
  }

  List<Widget> _buildMenuItemsSettings(BuildContext context) {
    final menuItems = [
      {'title': 'Trợ giúp & hỗ trợ', 'screen': HelpSupportScreen(), 'icon': Icons.help},
      {'title': 'Cài đặt', 'screen': SettingsScreen(), 'icon': Icons.settings},
    ];

    return menuItems.map((item) {
      return _buildMenuItem(item['title'] as String, context, item['screen'] as Widget, item['icon'] as IconData);
    }).toList();
  }

  List<Widget> _buildMenuItemsAlbum(BuildContext context) {
    final menuItems = [
      {'title': 'Nhạc của tôi', 'screen': MyMusicScreen(), 'icon': Icons.library_music},
      {'title': 'Nhạc yêu thích', 'screen': MyLikedScreen(), 'icon': Icons.favorite},
      {'title': 'Album đã lưu', 'screen': AlbumScreen(), 'icon': Icons.album},
      {'title': 'Tin nhắn', 'screen': SentMessagesScreen(), 'icon': Icons.message_outlined},
    ];

    return menuItems.map((item) {
      return _buildMenuItem(item['title'] as String, context, item['screen'] as Widget, item['icon'] as IconData);
    }).toList();
  }

  Widget _buildMenuItem(String title, BuildContext context, Widget screen, IconData icon, {bool fullWidth = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2, // Adjust elevation
        child: Container(
          height: 80, // Set fixed height for each card
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20), // Reduced padding inside the card
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: Colors.orange), // Adjusted icon size
              SizedBox(width: 15), // Reduced height between icon and text
              Expanded(
                // Allows the text to use available space and wrap if needed
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.visible, // Allow text to wrap to new line
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
