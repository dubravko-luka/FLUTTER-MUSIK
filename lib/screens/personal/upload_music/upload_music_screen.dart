import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart'; // sử dụng audioplayer để phát âm thanh
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:musik/common/config.dart';

class UploadMusicScreen extends StatefulWidget {
  @override
  _UploadMusicScreenState createState() => _UploadMusicScreenState();
}

class _UploadMusicScreenState extends State<UploadMusicScreen> {
  String _selectedFile = 'No file selected.';
  FilePickerResult? _file;
  AudioPlayer _audioPlayer = AudioPlayer();
  TextEditingController _descriptionController = TextEditingController();
  final storage = FlutterSecureStorage();
  bool _isLoading = false;
  double _progress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);

    if (result != null) {
      _file = result;
      setState(() {
        _selectedFile = _file!.files.single.name;
      });
      _setupAudioElement();
    } else {
      // User canceled the picker
    }
  }

  void _setupAudioElement() async {
    if (_file != null) {
      await _audioPlayer.setFilePath(_file!.files.single.path!);
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
          _progress = position.inMilliseconds / _audioPlayer.duration!.inMilliseconds;
        });
      });

      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });
    }
  }

  Future<void> _uploadMusic() async {
    if (_file == null) {
      _showMessage('No file selected');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = await storage.read(key: 'authToken');
    if (token == null) {
      _showMessage('Authentication token not found');
      return;
    }

    final uri = Uri.parse('$baseUrl/upload_music');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = token
          ..fields['description'] = _descriptionController.text;

    request.files.add(await http.MultipartFile.fromPath('file', _file!.files.single.path!));

    final response = await request.send();

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      _showMessage('Music uploaded successfully.');
      _resetForm();
    } else {
      _showMessage('Failed to upload music');
    }
  }

  void _showMessage(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.top,
      backgroundColor: Colors.black54,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      duration: Duration(seconds: 3),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedFile = 'No file selected.';
      _audioPlayer.pause();
      _audioPlayer.stop();
      _file = null;
      _descriptionController.clear();
      _progress = 0.0;
      _duration = Duration.zero;
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _playMusic() {
    _audioPlayer.play();
  }

  void _pauseMusic() {
    _audioPlayer.pause();
  }

  void _seekMusic(double seconds) {
    _audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.tealAccent.shade100,
          title: Text('Confirm', style: TextStyle(color: Colors.teal)),
          content: Text('Do you really want to exit?', style: TextStyle(color: Colors.black87)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: TextStyle(color: Colors.teal))),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('OK', style: TextStyle(color: Colors.teal))),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tải nhạc lên'),
          backgroundColor: Colors.tealAccent.shade100,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit) {
                _resetForm();
                Navigator.pop(context);
              }
            },
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Select Music File',
                          prefixIcon: Icon(Icons.upload_file),
                          suffixIcon: _file != null ? Icon(Icons.check, color: Colors.green) : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        readOnly: true,
                        controller: TextEditingController(text: _selectedFile),
                        onTap: _pickFile,
                      ),
                      SizedBox(height: 15),
                      if (_file != null) _musicReview(),
                      SizedBox(height: 15),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Describe your mood',
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 30),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _uploadMusic,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.teal,
                              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: Text('Upload'),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _musicReview() {
    return Row(
      children: [
        IconButton(
          icon: Icon(_audioPlayer.playerState.playing ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (_audioPlayer.playerState.playing) {
              _pauseMusic();
            } else {
              _playMusic();
            }
          },
        ),
        Text(_formatDuration(_position)),
        Expanded(
          child: Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble(),
            onChanged: (value) {
              _seekMusic(value);
            },
          ),
        ),
        Text(_formatDuration(_duration)),
      ],
    );
  }
}
