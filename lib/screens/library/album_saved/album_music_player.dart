import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:musik/widgets/bottom-sheet/friend_options_sheet.dart';
import 'package:musik/common/config.dart';
import 'package:musik/widgets/success_popup.dart';

class AlbumMusicPlayer extends StatefulWidget {
  final int id;
  final int albumId;
  final String avatar;
  final String url;
  final int user_id;
  final String name;
  final String description;
  final int currentPlayingId;
  final Function(int id) setPlayingId;
  final Function(int id) onMusicRemoved;

  AlbumMusicPlayer({
    required this.id,
    required this.albumId,
    required this.user_id,
    required this.avatar,
    required this.url,
    required this.name,
    required this.description,
    required this.currentPlayingId,
    required this.setPlayingId,
    required this.onMusicRemoved,
  });

  @override
  _AlbumMusicPlayerState createState() => _AlbumMusicPlayerState();
}

class _AlbumMusicPlayerState extends State<AlbumMusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final storage = FlutterSecureStorage();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAudio();
    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _handlePlaybackComplete();
      }
    });
  }

  void _setupAudio() async {
    try {
      await _audioPlayer.setUrl(widget.url);
    } catch (e) {
      print("Error setting URL album music player: $e");
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
  void didUpdateWidget(AlbumMusicPlayer oldWidget) {
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

  Future<void> _removeMusic() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final url = Uri.parse('$baseUrl/remove_music_from_album');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'album_id': widget.albumId, 'music_id': widget.id}),
    );

    if (response.statusCode == 200) {
      SuccessPopup(message: 'Xóa nhạc thành công', outerContext: context).show();
      widget.onMusicRemoved(widget.id);
    } else {
      SuccessPopup(message: 'Không thể xóa nhạc', outerContext: context).show(success: false);
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FriendOptionsSheet(name: widget.name, avatarUrl: widget.avatar, profileUserId: widget.user_id),
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
            GestureDetector(onTap: () => _showBottomSheet(context), child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(widget.avatar))),
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
            Column(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(Icons.bookmark, color: Colors.teal), onPressed: _removeMusic)]),
          ],
        ),
      ),
    );
  }
}
