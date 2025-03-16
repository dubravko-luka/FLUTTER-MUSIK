import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:musik/common/config.dart';
import 'package:musik/widgets/success_popup.dart';

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
    Uri.parse('$baseUrl/list_albums'),
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
          backgroundColor: Colors.white,
          title: Text('Chọn album', style: TextStyle(color: Colors.orange)),
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
              child: Text('Từ chối', style: TextStyle(color: Colors.orange)),
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

  final url = Uri.parse('$baseUrl/add_music_to_album');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'Authorization': token},
    body: jsonEncode({'album_id': albumId, 'music_id': musicId}),
  );

  if (response.statusCode == 201) {
    SuccessPopup(message: 'Thêm thành công', outerContext: context).show();
    onAddedToAlbum(); // Call the callback to update the state
  }
}
