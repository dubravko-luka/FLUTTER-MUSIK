import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musik/common/config.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:musik/services/auth_service.dart';
import 'package:musik/widgets/success_popup.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final storage = FlutterSecureStorage();
  final picker = ImagePicker();
  String? _name;
  String? _email;
  String? _avatarUrl;
  int? _userId; // Add _userId here
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.get(Uri.parse('$baseUrl/user_info'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _userId = data['id']; // Initialize _userId
        _name = data['name'];
        _email = data['email'];
        _avatarUrl = '${baseUrl}/get_avatar/$_userId';
        _isLoading = false;
      });
    } else {
      return;
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      final token = await storage.read(key: 'authToken');
      if (token == null) {
        return;
      }

      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      Uint8List fileBytes = await pickedFile.readAsBytes();
      String fileName = pickedFile.name;

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_avatar'))
            ..headers['Authorization'] = token
            ..files.add(http.MultipartFile.fromBytes('avatar', fileBytes, filename: fileName));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        SuccessPopup(message: 'Cập nhật avatar thành công', outerContext: context).show();
        setState(() {
          _avatarUrl = generateAvatarUrl(_userId!); // Use _userId here
        });
        _authService.fetchAndStoreUserInfo(token);
      } else {
        SuccessPopup(message: 'Cập nhật avatar thất bại', outerContext: context).show(success: false);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _updateName(String newName) async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/update_user_info'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'name': newName, 'email': _email}),
    );

    if (response.statusCode == 200) {
      SuccessPopup(message: 'Cập nhật thành công', outerContext: context).show();
      _fetchUserInfo();
    } else {
      SuccessPopup(message: 'Cập nhật thất bại', outerContext: context).show(success: false);
    }
  }

  void _showEditNameDialog() {
    TextEditingController controller = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.tealAccent.shade100,
            title: Text('Edit Name'),
            content: TextField(controller: controller, decoration: InputDecoration(hintText: 'Enter your name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  String newName = controller.text.trim();
                  if (newName.isNotEmpty) _updateName(newName);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  String generateAvatarUrl(int userId) {
    return '$baseUrl/get_avatar/$userId?${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.tealAccent.shade100,
                                    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                                    child: _avatarUrl == null ? Icon(Icons.person, size: 60, color: Colors.teal.shade600) : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: FloatingActionButton(
                                      onPressed: _uploadAvatar,
                                      mini: true,
                                      backgroundColor: Colors.teal,
                                      child: Icon(Icons.edit, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildEditableInfoRow('Name:', _name ?? 'Loading...'),
                                    Divider(),
                                    _buildInfoRow('Email:', _email ?? 'Loading...'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEditableInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal)),
        Row(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
            IconButton(icon: Icon(Icons.edit, color: Colors.teal), onPressed: _showEditNameDialog),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
      ],
    );
  }
}
