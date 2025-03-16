import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musik/services/music_service.dart';
import 'package:musik/controllers/audio_controller.dart';
import 'package:musik/screens/library/album_saved/album_selection_dialog.dart';

class MusicPlayer extends StatefulWidget {
  final int id;
  final String url;
  final String avatar;
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
    required this.avatar,
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
  final AudioController _audioController = AudioController();
  final MusicService _musicService = MusicService();
  bool isPlaying = false;
  late bool _inAlbum;

  @override
  void initState() {
    super.initState();
    _inAlbum = widget.inAlbum;
    _setupAudio();
  }

  void _setupAudio() async {
    try {
      await _audioController.setUrl(widget.url);
    } catch (e) {
      print("Error setting URL: $e");
    }
  }

  @override
  void didUpdateWidget(MusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPlayingId != widget.id) {
      setState(() {
        isPlaying = false;
      });
      _audioController.pause();
    }
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      widget.setPlayingId(-1);
      setState(() {
        isPlaying = false;
      });
      _audioController.pause();
    } else {
      if (_audioController.audioPlayer.processingState ==
          ProcessingState.completed) {
        await _audioController.seek(Duration.zero);
      }
      setState(() {
        isPlaying = true;
      });
      if (widget.id != widget.currentPlayingId) {
        _setupAudio();
      }
      widget.setPlayingId(widget.id);
      _audioController.play();
    }
  }

  Future<void> _removeFromAlbum() async {
    try {
      await _musicService.removeFromAlbum(widget.albumId ?? -1, widget.id);
      setState(() {
        _inAlbum = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _audioController.dispose();
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
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.orange,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      StreamBuilder<Duration>(
                        stream: _audioController.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          return Text(
                            position.toString().split('.').first,
                            style: TextStyle(color: Colors.black54),
                          );
                        },
                      ),
                      Expanded(
                        child: StreamBuilder<Duration?>(
                          stream: _audioController.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: _audioController.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                return Slider(
                                  value: position.inMilliseconds.toDouble(),
                                  max:
                                      duration.inMilliseconds.toDouble() > 0
                                          ? duration.inMilliseconds.toDouble()
                                          : 1.0,
                                  onChanged: (value) async {
                                    await _audioController.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  },
                                  activeColor: Colors.orange,
                                  inactiveColor: Colors.orange.shade100,
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
                Icon(Icons.share, color: Colors.orange),
                IconButton(
                  icon: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.orange,
                  ),
                  onPressed: widget.onToggleLike,
                ),
                IconButton(
                  icon: Icon(
                    _inAlbum ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    if (_inAlbum) {
                      _removeFromAlbum();
                    } else {
                      showAlbumSelectionDialog(context, widget.id, () {
                        setState(() {
                          _inAlbum = true;
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
