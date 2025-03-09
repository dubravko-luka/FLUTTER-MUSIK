import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'music_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = FlutterSecureStorage();
  List<dynamic> _songs = [];
  bool _isLoading = true;
  int _currentPlayingId = -1;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      // Handle missing token
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/list_music'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        final List<dynamic> songs = jsonDecode(response.body);
        _songs =
            songs.map((song) {
              song['liked'] = song['liked'] == 1;
              song['in_album'] = song['in_album'] == 1;
              return song;
            }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _toggleLike(int songId, bool isLiked) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      // Handle missing token
      return;
    }

    final endpoint = isLiked ? '/unlike_music/$songId' : '/like_music/$songId';
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000$endpoint'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _songs =
            _songs.map((song) {
              if (song['id'] == songId) {
                song['liked'] = !isLiked;
              }
              return song;
            }).toList();
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
          'Musik',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
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
                    final isLiked = song['liked'] ?? false;
                    final inAlbum = song['in_album'] ?? false;
                    final url =
                        'http://127.0.0.1:5000/get_music_file/${song['id']}';

                    return MusicPlayer(
                      id: song['id'],
                      url: url,
                      name: name,
                      user_id: song['user_id'],
                      description: description,
                      currentPlayingId: _currentPlayingId,
                      setPlayingId: (int songId) {
                        setState(() {
                          _currentPlayingId = songId;
                        });
                      },
                      albumId: song['album_id'],
                      isLiked: isLiked,
                      inAlbum: inAlbum,
                      onToggleLike: () {
                        _toggleLike(song['id'], isLiked);
                      },
                    );
                  },
                ),
              ),
    );
  }
}
