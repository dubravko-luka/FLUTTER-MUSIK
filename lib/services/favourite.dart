import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/common/config.dart';

class FavouriteService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> handleToggleLike(int songId, bool isLiked, List<dynamic> _songs, void Function(void Function()) setState, bool mounted) async {
    try {
      await _toggleLike(songId, isLiked);
      if (!mounted) return;
      setState(() {
        _songs =
            _songs.map((song) {
              if (song['id'] == songId) {
                song['liked'] = !isLiked;
              }
              return song;
            }).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleLike(int songId, bool isLiked) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      throw Exception('Missing token');
    }

    final endpoint = isLiked ? '/unlike_music/$songId' : '/like_music/$songId';
    final response = await http.post(Uri.parse('$baseUrl$endpoint'), headers: {'Authorization': token});

    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      throw Exception('Failed to toggle like');
    }
  }
}
