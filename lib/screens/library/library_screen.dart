import 'package:flutter/material.dart';
import 'package:musik/screens/(common)/sent_messages_screen.dart';
import 'package:musik/screens/library/album_saved/album_screen.dart';
import 'package:musik/screens/library/liked_music/my_liked_screen.dart';
import 'package:musik/screens/library/my_music/my_music_screen.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      {'title': 'Nhạc của tôi', 'screen': MyMusicScreen(), 'icon': Icons.library_music},
      {'title': 'Nhạc yêu thích', 'screen': MyLikedScreen(), 'icon': Icons.favorite},
      {'title': 'Album đã lưu', 'screen': AlbumScreen(), 'icon': Icons.album},
      {'title': 'Tin nhắn', 'screen': SentMessagesScreen(), 'icon': Icons.message_outlined},
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
