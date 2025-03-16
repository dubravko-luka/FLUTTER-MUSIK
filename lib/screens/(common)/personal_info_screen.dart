import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musik/common/config.dart';
import 'package:musik/services/auth_service.dart';
import 'package:musik/services/music_service.dart';
import 'package:musik/screens/(common)/music_player.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final int profileUserId;

  PersonalInfoScreen({
    required this.name,
    required this.avatarUrl,
    required this.profileUserId,
  });

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final storage = FlutterSecureStorage();
  final picker = ImagePicker();
  final MusicService _musicService = MusicService();
  final AuthService _authService = AuthService();

  List<dynamic> _songs = [];
  bool _isLoadingSongs = true;
  int _currentPlayingId = -1;

  @override
  void initState() {
    super.initState();
    _loadUserSongs();
  }

  Future<void> _loadUserSongs() async {
    try {
      final songs = await _musicService.fetchSongsByUser(
        context,
        widget.profileUserId,
      );
      setState(() {
        _songs = songs;
        _isLoadingSongs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSongs = false;
      });
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
      // Hiển thị thông báo lỗi nếu muốn
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent.shade100,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/background.png',
            ), // Path to your background image
            fit: BoxFit.cover, // Cover the whole screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    widget.avatarUrl.isNotEmpty
                        ? NetworkImage(widget.avatarUrl)
                        : null,
                child:
                    widget.avatarUrl.isEmpty
                        ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.orange.shade600,
                        )
                        : null,
              ),
              SizedBox(height: 30),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildInfoRow('Name:', widget.name),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child:
                    _isLoadingSongs
                        ? Center(child: CircularProgressIndicator())
                        : _songs.isEmpty
                        ? Center(child: Text('No songs found.'))
                        : ListView.builder(
                          itemCount: _songs.length,
                          itemBuilder: (context, index) {
                            final song = _songs[index];
                            return MusicPlayer(
                              id: song['id'],
                              url: '$baseUrl/get_music_file/${song['id']}',
                              name: song['user_name'] ?? 'Unknown Name',
                              avatar: _authService.generateAvatarUrl(
                                song['user_id'],
                              ),
                              user_id: song['user_id'],
                              description:
                                  song['description'] ?? 'No Description',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.orange,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
