import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final storage = FlutterSecureStorage();
  String? _name;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) {
      // Handle missing token (e.g., redirect to login)
      return;
    }

    final response = await http.get(Uri.parse('http://127.0.0.1:5000/user_info'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _name = data['name'];
        _email = data['email'];
        _isLoading = false;
      });
    } else {
      // Handle error
      print("Failed to load user info");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.tealAccent.shade100,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                                    child: CircleAvatar(
                                      radius: 56,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.person, size: 60, color: Colors.teal.shade600),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: FloatingActionButton(
                                      onPressed: () {},
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
                                    _buildInfoRow('Name:', _name ?? 'Loading...'),
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
