import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/common/config.dart';
import 'package:musik/services/auth_service.dart';
import 'package:musik/services/favourite.dart';
import 'package:musik/widgets/music_player/music_player.dart';
import 'package:musik/widgets/bottom-sheet/friend_options_sheet.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  final FavouriteService _favouriteService = FavouriteService();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<dynamic> _musicResults = [];
  List<dynamic> _userResults = [];
  bool _isLoading = false;
  int _currentPlayingId = -1;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final token = await storage.read(key: 'authToken');
    if (token == null) {
      setState(() {
        _error = 'Token is missing!';
        _isLoading = false;
      });
      return;
    }

    try {
      final musicResponse = await http.get(
        Uri.parse('$baseUrl/search_music?query=$query'),
        headers: {'Authorization': token},
      );

      final userResponse = await http.get(
        Uri.parse('$baseUrl/search_users?query=$query'),
        headers: {'Authorization': token},
      );

      if (musicResponse.statusCode == 200) {
        List<dynamic> songs = jsonDecode(musicResponse.body);

        songs =
            songs
                .map(
                  (song) => {
                    ...song,
                    'liked': song['liked'] == 1,
                    'in_album': song['in_album'] == 1,
                  },
                )
                .toList();

        setState(() {
          _musicResults = songs;
        });
      }

      if (userResponse.statusCode == 200) {
        setState(() {
          _userResults = json.decode(userResponse.body);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Từ khoá tìm kiếm',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
          style: TextStyle(color: Colors.black),
          onSubmitted: _performSearch,
          onChanged: (query) {
            if (query.isEmpty) {
              setState(() {
                _musicResults.clear();
                _userResults.clear();
              });
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Nhạc'), Tab(text: 'Người dùng')],
        ),
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_error.isNotEmpty)
                Center(child: Text(_error))
              else
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildMusicList(), _buildUserList()],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicList() {
    if (_musicResults.isEmpty) {
      return Center(child: Text('No music found'));
    }
    return ListView.builder(
      itemCount: _musicResults.length,
      itemBuilder: (context, index) {
        final song = _musicResults[index];
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
              _musicResults,
              setState,
              mounted,
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => FriendOptionsSheet(
            name: friend['name'],
            avatarUrl: _authService.generateAvatarUrl(friend['id']),
            profileUserId: friend['id'],
          ),
    );
  }

  Widget _buildUserList() {
    if (_userResults.isEmpty) {
      return Center(child: Text('No users found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final friend = _userResults[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                _authService.generateAvatarUrl(friend['id']),
              ),
            ),
            title: Text(
              friend['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(friend['email']),
            trailing: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.teal),
              onPressed: () {
                _showBottomSheet(context, friend);
              },
            ),
          ),
        );
      },
    );
  }
}
