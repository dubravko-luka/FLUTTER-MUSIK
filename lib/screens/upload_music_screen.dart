import 'package:flutter/material.dart';

class UploadMusicScreen extends StatefulWidget {
  @override
  _UploadMusicScreenState createState() => _UploadMusicScreenState();
}

class _UploadMusicScreenState extends State<UploadMusicScreen> {
  String _selectedFile = 'Chưa có file nào được chọn.';
  TextEditingController _descriptionController = TextEditingController();

  void _pickFile() {
    // Add your file picker logic here
    setState(() {
      _selectedFile = 'example.mp3'; // Example file name after picking
    });
  }

  void _uploadMusic() {
    // Add your upload logic here
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
            Navigator.pop(context); // This will go back to the previous screen
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Upload Music', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Chọn file nhạc',
                        prefixIcon: Icon(Icons.upload_file),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      readOnly: true,
                      onTap: _pickFile,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả tâm trạng của bạn',
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _uploadMusic,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.teal,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Tải lên'),
                    ),
                    SizedBox(height: 20),
                    Text('Đã chọn: $_selectedFile', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
