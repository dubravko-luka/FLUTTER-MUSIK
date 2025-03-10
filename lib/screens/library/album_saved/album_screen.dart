import 'dart:convert';
import 'package:flutter/material.dart';
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
      _showMessage('Authentication token not found');
      return;
    }

    final response = await http.get(Uri.parse('http://10.50.80.162:5000/list_albums'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        albums =
            data
                .map((album) => {'id': album['id'], 'name': album['name'], 'created_at': album['created_at'], 'track_count': album['track_count']})
                .toList();
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to load albums');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Album đã lưu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      return _buildAlbumCard(albums[index]);
                    },
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAlbumDialog,
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateAlbumDialog() {
    TextEditingController albumNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.tealAccent.shade100,
          title: Text('Create New Album', style: TextStyle(color: Colors.teal)),
          content: TextField(
            controller: albumNameController,
            decoration: InputDecoration(
              hintText: 'Enter album name',
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.teal)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.teal)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () async {
                String albumName = albumNameController.text;
                await _createAlbum(albumName);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createAlbum(String albumName) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      _showMessage('Authentication token not found');
      return;
    }

    final url = Uri.parse('http://10.50.80.162:5000/create_album');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'name': albumName}),
    );

    if (response.statusCode == 201) {
      _showMessage('Album created successfully');
      _fetchAlbums();
    } else {
      _showMessage('Failed to create album');
    }
  }

  void _showEditAlbumDialog(int albumId, String currentName) {
    TextEditingController albumNameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.tealAccent.shade100,
          title: Text('Edit Album Name', style: TextStyle(color: Colors.teal)),
          content: TextField(
            controller: albumNameController,
            decoration: InputDecoration(
              hintText: 'Enter new album name',
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.teal)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.teal)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = albumNameController.text;
                await _editAlbumName(albumId, newName);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
      _showMessage('Authentication token not found');
      return;
    }

    final url = Uri.parse('http://10.50.80.162:5000/edit_album_name');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'album_id': albumId, 'name': newName}),
    );

    if (response.statusCode == 200) {
      _showMessage('Album name updated successfully');
      _fetchAlbums();
    } else {
      _showMessage('Failed to update album name');
    }
  }

  Widget _buildAlbumCard(Map<String, dynamic> album) {
    final format = DateFormat('yyyy-MM-dd');
    final createdAt = DateTime.parse(album['created_at']);
    final trackCount = album['track_count'];

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumMusicScreen(albumId: album['id'])));
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(format.format(createdAt), style: TextStyle(fontSize: 14, color: Colors.grey[700]), textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text('$trackCount track(s)', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.teal),
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
