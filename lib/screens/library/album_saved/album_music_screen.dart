import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:musik/common/config.dart';
import 'package:musik/services/auth_service.dart';
import 'album_music_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AlbumMusicScreen extends StatefulWidget {
  final int albumId;

  AlbumMusicScreen({required this.albumId});

  @override
  _AlbumMusicScreenState createState() => _AlbumMusicScreenState();
}

class _AlbumMusicScreenState extends State<AlbumMusicScreen> {
  List<dynamic> _songs = [];
  final storage = FlutterSecureStorage();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  int _currentPlayingId = -1;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchSongs() async {
    String? token = await storage.read(key: "authToken");
    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/list_album_music/${widget.albumId}'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load songs')));
    }
  }

  void _removeSongFromList(int songId) {
    setState(() {
      _songs.removeWhere((song) => song['id'] == songId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Album Music',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    final url = '$baseUrl/get_music_file/${song['id']}';
                    final avatar = _authService.generateAvatarUrl(
                      song['user_id'],
                    );

                    return AlbumMusicPlayer(
                      id: song['id'],
                      albumId: widget.albumId,
                      url: url,
                      user_id: song['user_id'],
                      avatar: avatar,
                      name: name,
                      description: description,
                      currentPlayingId: _currentPlayingId,
                      setPlayingId: (int songId) {
                        setState(() {
                          _currentPlayingId = songId;
                        });
                      },
                      onMusicRemoved: _removeSongFromList,
                    );
                  },
                ),
              ),
    );
  }
}
