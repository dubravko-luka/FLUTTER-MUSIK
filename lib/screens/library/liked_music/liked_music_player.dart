import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class LikedMusicPlayer extends StatefulWidget {
  final int id;
  final String url;
  final String name;
  final String description;
  final int currentPlayingId;
  final Function(int id) setPlayingId;
  final bool isLiked;
  final VoidCallback onToggleLike;

  LikedMusicPlayer({
    required this.id,
    required this.url,
    required this.name,
    required this.description,
    required this.currentPlayingId,
    required this.setPlayingId,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  _LikedMusicPlayerState createState() => _LikedMusicPlayerState();
}

class _LikedMusicPlayerState extends State<LikedMusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
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
      print("Error setting URL: $e");
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
  void didUpdateWidget(LikedMusicPlayer oldWidget) {
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
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.person, color: Colors.teal, size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
                          color: Colors.teal,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      StreamBuilder<Duration>(
                        stream: _audioPlayer.positionStream,
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
                          stream: _audioPlayer.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: _audioPlayer.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                return Slider(
                                  value: position.inMilliseconds.toDouble(),
                                  max:
                                      duration.inMilliseconds.toDouble() > 0
                                          ? duration.inMilliseconds.toDouble()
                                          : 1.0,
                                  onChanged: (value) async {
                                    await _audioPlayer.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
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
                IconButton(
                  icon: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.teal,
                  ),
                  onPressed: widget.onToggleLike,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
