import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageUtil {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> writeToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: 'authToken');
  }
}
