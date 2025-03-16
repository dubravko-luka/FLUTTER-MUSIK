import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:musik/common/config.dart';
import 'package:musik/widgets/success_popup.dart';
import 'album_music_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class AlbumScreen extends StatefulWidget {
  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/list_albums'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        albums =
            data
                .map(
                  (album) => {
                    'id': album['id'],
                    'name': album['name'],
                    'created_at': album['created_at'],
                    'track_count': album['track_count'],
                  },
                )
                .toList();
        _isLoading = false;
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Album đã lưu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent.shade100,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
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
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      return _buildAlbumCard(albums[index]);
                    },
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreaorangebumDialog,
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreaorangebumDialog() {
    TextEditingController albumNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          title: Text('Tạo album mới', style: TextStyle(color: Colors.orange)),
          content: TextField(
            controller: albumNameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên album',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),

              filled: true,
              fillColor: Colors.white,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Từ chối', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () async {
                String albumName = albumNameController.text;
                _creaorangebum(albumName);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Đồng ý', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _creaorangebum(String albumName) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final url = Uri.parse('$baseUrl/create_album');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'name': albumName}),
    );

    if (response.statusCode == 201) {
      SuccessPopup(
        message: 'Tạo album thành công',
        outerContext: context,
      ).show();
      _fetchAlbums();
    } else {
      SuccessPopup(
        message: 'Tạo album thất bại',
        outerContext: context,
      ).show(success: false);
    }
  }

  void _showEditAlbumDialog(int albumId, String currentName) {
    TextEditingController albumNameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          title: Text(
            'Chỉnh sửa tên album',
            style: TextStyle(color: Colors.orange),
          ),
          content: TextField(
            controller: albumNameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên album',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = albumNameController.text;
                _editAlbumName(albumId, newName);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editAlbumName(int albumId, String newName) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final url = Uri.parse('$baseUrl/edit_album_name');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'album_id': albumId, 'name': newName}),
    );

    if (response.statusCode == 200) {
      SuccessPopup(
        message: 'Cập nhật thành công',
        outerContext: context,
      ).show();
      _fetchAlbums();
    } else {
      SuccessPopup(
        message: 'Thất bại',
        outerContext: context,
      ).show(success: false);
    }
  }

  Widget _buildAlbumCard(Map<String, dynamic> album) {
    final format = DateFormat('yyyy-MM-dd');
    final createdAt = DateTime.parse(album['created_at']);
    final trackCount = album['track_count'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    AlbumMusicScreen(albumId: album['id'], name: album['name']),
          ),
        ).then((_) => _fetchAlbums());
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    album['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    format.format(createdAt),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$trackCount track(s)',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  _showEditAlbumDialog(album['id'], album['name']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
