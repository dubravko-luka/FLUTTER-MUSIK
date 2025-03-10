import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musik/common/config.dart';
import 'package:musik/utils/storage_util.dart';

class AuthService {
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
      await StorageUtil.writeToken(token);

      return true;
    }

    return false;
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
}
