import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Câu hỏi thường gặp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              SizedBox(height: 10),
              _buildFAQTile('Làm thế nào để tạo tài khoản?', Icons.person_add, () {
                // Navigate to answer or show dialog
              }),
              _buildFAQTile('Cách thức tải nhạc lên?', Icons.cloud_upload, () {
                // Navigate to answer or show dialog
              }),
              SizedBox(height: 30),
              Text('Liên hệ chúng tôi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              SizedBox(height: 10),
              _buildContactTile(Icons.email, 'support@example.com', () {
                // Open email client
              }),
              _buildContactTile(Icons.phone, '+123 456 7890', () {
                // Initiate phone call
              }),
              Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implement additional support actions
                  },
                  icon: Icon(Icons.support),
                  label: Text('Liên hệ ngay'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.teal,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String info, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(leading: Icon(icon, color: Colors.teal), title: Text(info, style: TextStyle(fontSize: 18)), onTap: onTap),
    );
  }
}
