import 'package:flutter/material.dart';
import 'package:musik/common/config.dart';
import 'package:musik/screens/music_player/music_player.dart';
import 'package:musik/services/music_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicService _musicService = MusicService();
  List<dynamic> _songs = [];
  bool _isLoading = true;
  int _currentPlayingId = -1;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _musicService.fetchSongs(context);
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, for example by showing a dialog
    }
  }

  Future<void> _handleToggleLike(int songId, bool isLiked) async {
    try {
      await _musicService.toggleLike(songId, isLiked);
      setState(() {
        _songs =
            _songs.map((song) {
              if (song['id'] == songId) {
                song['liked'] = !isLiked;
              }
              return song;
            }).toList();
      });
    } catch (e) {
      // Handle error, for example by showing a dialog
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Musik', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    return MusicPlayer(
                      id: song['id'],
                      url: '$baseUrl/get_music_file/${song['id']}',
                      name: song['user_name'] ?? 'Unknown Name',
                      avatar: '$baseUrl/get_avatar/${song['user_id']}',
                      user_id: song['user_id'],
                      description: song['description'] ?? 'No Description',
                      currentPlayingId: _currentPlayingId,
                      setPlayingId: (int songId) {
                        setState(() {
                          _currentPlayingId = songId;
                        });
                      },
                      albumId: song['album_id'],
                      isLiked: song['liked'] ?? false,
                      inAlbum: song['in_album'] ?? false,
                      onToggleLike: () {
                        _handleToggleLike(song['id'], song['liked']);
                      },
                    );
                  },
                ),
              ),
    );
  }
}
