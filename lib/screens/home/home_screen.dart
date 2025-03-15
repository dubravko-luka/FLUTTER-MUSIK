import 'package:flutter/material.dart';
import 'package:musik/common/config.dart';
import 'package:musik/screens/(common)/search_screen.dart';
import 'package:musik/widgets/music_player/music_player.dart';
import 'package:musik/services/auth_service.dart';
import 'package:musik/services/favourite.dart';
import 'package:musik/services/music_service.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final MusicService _musicService = MusicService();
  final AuthService _authService = AuthService();
  final FavouriteService _favouriteService = FavouriteService();
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
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      final songs = await _musicService.fetchSongs(context);
      if (!mounted) return;
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadSongs();
  }

  @override
  void didPush() {
    _loadSongs();
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
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
                      avatar: _authService.generateAvatarUrl(song['user_id']),
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
                        _favouriteService.handleToggleLike(
                          song['id'],
                          song['liked'],
                          _songs,
                          setState,
                          mounted,
                        );
                      },
                    );
                  },
                ),
              ),
    );
  }
}
