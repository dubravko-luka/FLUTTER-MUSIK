import 'package:flutter/material.dart';
import 'package:musik/screens/library/album_saved/album_screen.dart';
import 'package:musik/screens/personal/friend_request/firend_request_screen.dart';
import 'package:musik/screens/library/liked_music/my_liked_screen.dart';
import 'package:musik/screens/library/my_music/my_music_screen.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thư viện của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            children: [..._buildMenuItems(context)],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'title': 'Nhạc của tôi', 'screen': MyMusicScreen()},
      {'title': 'Nhạc yêu thích', 'screen': MyLikedScreen()},
      {'title': 'Album đã lưu', 'screen': AlbumScreen()},
      {'title': 'Nhạc đã xoá', 'screen': FriendRequestsScreen()},
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
