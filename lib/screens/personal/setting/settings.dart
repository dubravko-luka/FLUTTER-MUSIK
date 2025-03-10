import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_language_dialog.dart';
import 'privacy_policy_screen.dart';
import 'about_app_screen.dart';
import '../../auth/login/login_screen.dart'; // Ensure you have a login screen

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Initial state for notifications

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
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
                _selectLanguage(context);
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.notifications,
              title: 'Thông báo',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // Save to SharedPreferences
                  _saveNotificationPreference(value);
                },
              ),
            ),
            _buildSettingTile(
              context,
              icon: Icons.lock,
              title: 'Quyền riêng tư',
              onTap: () {
                _showPrivacySettings(context);
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.info,
              title: 'Giới thiệu về ứng dụng',
              onTap: () {
                _showAboutApp(context);
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

  Future<void> _selectLanguage(BuildContext context) async {
    // Show a dialog for language selection
    showLanguageDialog(context);
  }

  void _saveNotificationPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  void _showPrivacySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
    );
  }

  void _showAboutApp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutAppScreen()),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
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
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
