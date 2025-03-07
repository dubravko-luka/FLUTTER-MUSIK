import 'package:flutter/material.dart';
import 'package:musik/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSettingTile(
              context,
              icon: Icons.language,
              title: 'Ngôn ngữ',
              subtitle: 'Tiếng Việt',
              onTap: () {
                // Add language selection logic here
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.notifications,
              title: 'Thông báo',
              trailing: Switch(
                value: true,
                onChanged: (bool value) {
                  // Add notification toggle logic here
                },
              ),
            ),
            _buildSettingTile(
              context,
              icon: Icons.lock,
              title: 'Quyền riêng tư',
              onTap: () {
                // Add privacy settings logic here
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.info,
              title: 'Giới thiệu về ứng dụng',
              onTap: () {
                // Add about app logic here
              },
            ),
            Divider(color: Colors.grey.shade800),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data

    // Navigate back to login screen and clear the navigation stack
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (Route<dynamic> route) => false);
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
