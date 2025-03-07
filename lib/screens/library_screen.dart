import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  final List<String> favoriteSongs = List.generate(10, (index) => 'Ánh nắng...');
  final List<String> savedSongs = List.generate(10, (index) => 'Ánh nắng...');
  final List<String> uploadedSongs = List.generate(10, (index) => 'Ánh nắng...');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: [
              _buildSongSection('Nhạc Yêu Thích', favoriteSongs, Icons.favorite),
              SizedBox(height: 20),
              _buildSongSection('Nhạc Đã Lưu', savedSongs, Icons.save),
              SizedBox(height: 20),
              _buildSongSection('Nhạc Đã Tải Lên', uploadedSongs, Icons.cloud_upload),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongSection(String title, List<String> songs, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return _buildSongCard(songs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongCard(String songTitle) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 70, color: Colors.white.withOpacity(0.7)),
          SizedBox(height: 10),
          Text(songTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          SizedBox(height: 10),
          Icon(Icons.play_circle_fill, color: Colors.tealAccent, size: 30),
        ],
      ),
    );
  }
}
