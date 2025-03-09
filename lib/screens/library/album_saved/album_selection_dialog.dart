import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void showAlbumSelectionDialog(
  BuildContext context,
  int musicId,
  VoidCallback onAddedToAlbum,
) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'authToken');
  if (token == null) {
    return;
  }

  final response = await http.get(
    Uri.parse('http://127.0.0.1:5000/list_albums'),
    headers: {'Authorization': token},
  );

  if (response.statusCode == 200) {
    final List<dynamic> albums = jsonDecode(response.body);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.tealAccent.shade100,
          title: Text('Select Album', style: TextStyle(color: Colors.teal)),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    albums[index]['name'],
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    addMusicToAlbum(
                      context,
                      albums[index]['id'],
                      musicId,
                      onAddedToAlbum,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }
}

Future<void> addMusicToAlbum(
  BuildContext context,
  int albumId,
  int musicId,
  VoidCallback onAddedToAlbum,
) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'authToken');
  if (token == null) {
    return;
  }

  final url = Uri.parse('http://127.0.0.1:5000/add_music_to_album');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'Authorization': token},
    body: jsonEncode({'album_id': albumId, 'music_id': musicId}),
  );

  if (response.statusCode == 201) {
    _showToastMessage(context, 'Music added to album successfully');
    onAddedToAlbum(); // Call the callback to update the state
  }
}

void _showToastMessage(BuildContext context, String message) {
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
