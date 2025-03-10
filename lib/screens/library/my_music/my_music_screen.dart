import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'my_music_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyMusicScreen extends StatefulWidget {
  @override
  _MyMusicScreenState createState() => _MyMusicScreenState();
}

class _MyMusicScreenState extends State<MyMusicScreen> {
  List<dynamic> _songs = [];
  final storage = FlutterSecureStorage();
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

    final response = await http.get(Uri.parse('http://10.50.80.162:5000/my_music'), headers: {'Authorization': token});
    if (response.statusCode == 200) {
      setState(() {
        _songs = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhạc của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    final name = song['name'] ?? 'Unknown Name';
                    final description = song['description'] ?? 'No Description';
                    final url = 'http://10.50.80.162:5000/get_music_file/${song['id']}';

                    return MyMusicPlayer(
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
                    );
                  },
                ),
              ),
    );
  }
}
