import 'package:flutter/material.dart';

class PostShortMusicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhạc ngắn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Tên bài nhạc')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add upload logic here
              },
              child: Text('Chọn File Nhạc'),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add post logic here
                },
                child: Text('Đăng tải'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
