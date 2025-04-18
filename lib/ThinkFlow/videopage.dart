import 'package:flutter/material.dart';

import 'package:thinkflow/ThinkFlow/coursvideo.dart';

class CourseVideosPage extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {
      'title': 'Introduction to the Course',
      'caption': 'Get an overview of what you will learn.',
      'path': 'assets/video1.mp4',
    },
    {
      'title': 'Understanding the Basics',
      'caption': 'Learn the fundamental concepts.',
      'path': 'assets/video2.mp4',
    },
    {
      'title': 'Deep Dive into the Topic',
      'caption': 'Explore in-depth details with examples.',
      'path': 'assets/video3.mp4',
    },
    {
      'title': 'Conclusion & What\'s Next',
      'caption': 'Wrap up and future steps.',
      'path': 'assets/video4.mp4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Course Videos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: Icon(Icons.play_circle_fill, color: Colors.orange, size: 40),
              title: Text(video['title']!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(video['caption']!, style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseVideoPlayer(videoUrl: video['path']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
