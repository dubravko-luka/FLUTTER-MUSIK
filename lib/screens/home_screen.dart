import 'package:flutter/material.dart';
import 'post_short_music_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> songs = [
    {'email': 'phuongnm@gmail.com', 'song': 'Ánh nắng của anh'},
    {'email': 'minh2214@gmail.com', 'song': 'Lạc trôi'},
    {'email': 'phuongnm@gmail.com', 'song': 'Ánh nắng của anh'},
    {'email': 'phuongnm@gmail.com', 'song': 'Ánh nắng của anh'},
    {'email': 'phuongnm@gmail.com', 'song': 'Ánh nắng của anh'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Musik', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.teal, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with Circular Avatars (Scrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap:
                          index == 0
                              ? () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PostShortMusicScreen()));
                              }
                              : null,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: Icon(index == 0 ? Icons.add : Icons.person, color: Colors.teal),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16), // Add spacing between avatars and cards
            // ListView of Songs
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 30, backgroundColor: Colors.teal.shade100, child: Icon(Icons.person, color: Colors.teal, size: 30)),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(songs[index]['email']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(songs[index]['song']!, style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(index == 1 ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.teal),
                                      onPressed: () {},
                                    ),
                                    Text('03:05', style: TextStyle(color: Colors.black54)),
                                    Expanded(
                                      child: Slider(value: 0.5, onChanged: (value) {}, activeColor: Colors.teal, inactiveColor: Colors.teal.shade100),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share, color: Colors.teal),
                              SizedBox(height: 8),
                              Icon(Icons.favorite_border, color: Colors.teal),
                              SizedBox(height: 8),
                              Icon(Icons.bookmark_border, color: Colors.teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
