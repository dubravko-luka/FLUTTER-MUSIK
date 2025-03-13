import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/common/config.dart';
import 'package:musik/services/auth_service.dart';

class MusicService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final AuthService _authService = AuthService();

  Future<List<dynamic>> fetchSongs(BuildContext context) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      throw Exception('Missing token');
    }

    final response = await http.get(Uri.parse('$baseUrl/list_music'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      final List<dynamic> songs = jsonDecode(response.body);
      return songs.map((song) => {...song, 'liked': song['liked'] == 1, 'in_album': song['in_album'] == 1}).toList();
    } else {
      _authService.handleInvalidToken(context);
      return [];
    }
  }

  Future<void> toggleLike(int songId, bool isLiked) async {
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

  Future<void> removeFromAlbum(int albumId, int musicId) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      throw Exception("Missing token");
    }

    final url = Uri.parse('$baseUrl/remove_music_from_album');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'album_id': albumId, 'music_id': musicId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove from album");
    }
  }
}
