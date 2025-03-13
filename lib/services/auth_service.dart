import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musik/common/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musik/screens/auth/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    final url = '$baseUrl/login';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      final token = responseJson['token'];

      // Save the token using secure storage
      await storage.write(key: 'authToken', value: token);

      // Fetch user information
      return await fetchAndStoreUserInfo(token);
    }

    return false;
  }

  Future<bool> fetchAndStoreUserInfo(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user_info'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final userInfo = jsonDecode(response.body);

      await storage.write(key: 'userId', value: userInfo['id'].toString());
      await storage.write(key: 'userName', value: userInfo['name']);
      await storage.write(key: 'userEmail', value: userInfo['email']);
      await storage.write(key: 'userAvatar', value: userInfo['avatar']);

      return true;
    }

    return false;
  }

  Future<void> getUserInfo(String token, BuildContext context) async {
    final response = await fetchAndStoreUserInfo(token);

    if (!response) {
      await handleInvalidToken(context);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final url = '$baseUrl/register';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> handleInvalidToken(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Call navigation only when the context is valid
    _navigateToLogin(context);
  }

  void _navigateToLogin(BuildContext context) {
    Future.microtask(() {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  String generateAvatarUrl(int userId) {
    return '$baseUrl/get_avatar/$userId?${DateTime.now().millisecondsSinceEpoch}';
  }
}
