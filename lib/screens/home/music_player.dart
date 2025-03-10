import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../library/album_saved/album_selection_dialog.dart';
import 'friend_options_sheet.dart'; // Ensure you have this component
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MusicPlayer extends StatefulWidget {
  final int id;
  final String url;
  final int? albumId;
  final String name;
  final int user_id;
  final String description;
  final int currentPlayingId;
  final Function(int id) setPlayingId;
  final bool isLiked;
  final bool inAlbum;
  final VoidCallback onToggleLike;

  MusicPlayer({
    required this.id,
    required this.url,
    required this.albumId,
    required this.name,
    required this.user_id,
    required this.description,
    required this.currentPlayingId,
    required this.setPlayingId,
    required this.isLiked,
    required this.inAlbum,
    required this.onToggleLike,
  });

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final storage = FlutterSecureStorage();
  bool isPlaying = false;
  late bool _inAlbum;

  @override
  void initState() {
    super.initState();
    _inAlbum = widget.inAlbum;
    _setupAudio();
    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _handlePlaybackComplete();
      }
    });
  }

  void _setupAudio() async {
    if (widget.url.isNotEmpty) {
      try {
        await _audioPlayer.setUrl(widget.url);
      } catch (e) {
        if (mounted) {
          print("Error setting URL music player: $e");
        }
      }
    }
  }

  void _handlePlaybackComplete() {
    setState(() {
      isPlaying = false;
    });
    widget.setPlayingId(-1);
    _audioPlayer.setUrl('');
  }

  @override
  void didUpdateWidget(MusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPlayingId != widget.id) {
      setState(() {
        isPlaying = false;
      });
      _audioPlayer.pause();
    }
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      widget.setPlayingId(-1);
      setState(() {
        isPlaying = false;
      });
      _audioPlayer.pause();
    } else {
      if (_audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
      }
      setState(() {
        isPlaying = true;
      });
      if (widget.id != widget.currentPlayingId) {
        _setupAudio();
      }
      widget.setPlayingId(widget.id);
      _audioPlayer.play();
    }
  }

  Future<void> _removeFromAlbum() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final url = Uri.parse('http://10.50.80.162:5000/remove_music_from_album');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'album_id': widget.albumId, 'music_id': widget.id}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _inAlbum = false;
      });
    } else {
      // Handle error
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => FriendOptionsSheet(
            name: widget.name,
            avatarUrl: "https://via.placeholder.com/150", // Replace with actual URL
            profileUserId: widget.user_id,
          ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showBottomSheet(context),
              child: CircleAvatar(radius: 30, backgroundColor: Colors.teal.shade100, child: Icon(Icons.person, color: Colors.teal, size: 30)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showBottomSheet(context),
                    child: Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Text(widget.description, style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.teal),
                        onPressed: _togglePlayPause,
                      ),
                      StreamBuilder<Duration>(
                        stream: _audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          return Text(position.toString().split('.').first, style: TextStyle(color: Colors.black54));
                        },
                      ),
                      Expanded(
                        child: StreamBuilder<Duration?>(
                          stream: _audioPlayer.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: _audioPlayer.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                return Slider(
                                  value: position.inMilliseconds.toDouble(),
                                  max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                                  onChanged: (value) async {
                                    await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                                  },
                                  activeColor: Colors.teal,
                                  inactiveColor: Colors.teal.shade100,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.share, color: Colors.teal),
                SizedBox(height: 8),
                IconButton(icon: Icon(widget.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.teal), onPressed: widget.onToggleLike),
                SizedBox(height: 8),
                IconButton(
                  icon: Icon(_inAlbum ? Icons.bookmark : Icons.bookmark_border, color: Colors.teal),
                  onPressed: () {
                    if (_inAlbum) {
                      _removeFromAlbum();
                    } else {
                      showAlbumSelectionDialog(context, widget.id, () {
                        setState(() {
                          _inAlbum = true; // Update the bookmark state
                        });
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
