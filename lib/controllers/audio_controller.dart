import 'package:just_audio/just_audio.dart';

class AudioController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> setUrl(String url) async {
    await _audioPlayer.setUrl(url);
  }

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
