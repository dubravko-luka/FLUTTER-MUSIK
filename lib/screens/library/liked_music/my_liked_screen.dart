import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'liked_music_player.dart';

class MyLikedScreen extends StatefulWidget {
  @override
  _MyLikedScreenState createState() => _MyLikedScreenState();
}

class _MyLikedScreenState extends State<MyLikedScreen> {
  final storage = FlutterSecureStorage();
  List<dynamic> _songs = [];
  bool _isLoading = true;
  int _currentPlayingId = -1;

  @override
  void initState() {
    super.initState();
    _fetchLikedSongs();
  }

  Future<void> _fetchLikedSongs() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      // Handle missing token by redirecting to login or showing an error
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/liked_music'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        _songs = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
    }
  }

  Future<void> _unlikeSong(int songId) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      // Handle missing token
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/unlike_music/$songId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        _songs = _songs.where((song) => song['id'] != songId).toList();
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài hát yêu thích',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final name = song['user_name'] ?? 'Unknown Name';
                    final description = song['description'] ?? 'No Description';
                    // Since this is the liked screen, we assume everything is liked.
                    final url =
                        'http://127.0.0.1:5000/get_music_file/${song['id']}';

                    return LikedMusicPlayer(
                      id: song['id'],
                      url: url,
                      name: name,
                      description: description,
                      currentPlayingId: _currentPlayingId,
                      setPlayingId: (int songId) {
                        setState(() {
                          _currentPlayingId = songId;
                        });
                      },
                      isLiked: true, // All songs in this list are liked
                      onToggleLike: () {
                        _unlikeSong(song['id']);
                      },
                    );
                  },
                ),
              ),
    );
  }
}
