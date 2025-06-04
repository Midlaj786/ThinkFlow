import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:thinkflow/thinkflow/user/video/videoplayer.dart';

class CourseVideosPage extends StatelessWidget {
  final String courseId;

  CourseVideosPage({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final courseDoc = FirebaseFirestore.instance.collection('courses').doc(courseId);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text("Course Videos", style: TextStyle(color: themeProvider.textColor)),
        backgroundColor: themeProvider.backgroundColor,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: courseDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Course not found.',
                style: TextStyle(color: themeProvider.textColor),
              ),
            );
          }

          final courseData = snapshot.data!.data()! as Map<String, dynamic>;

          final List videos = courseData['videos'] ?? [];

          if (videos.isEmpty) {
            return Center(
              child: Text(
                'No videos found for this course.',
                style: TextStyle(color: themeProvider.textColor),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index] as Map<String, dynamic>;
              final caption = video['caption'] ?? '';
              final videoUrl = video['url'] ?? '';
              final title = video['title']; // You can customize title if you want

              return Card(
                color: Colors.grey[200],
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Icon(Icons.play_circle_fill, color: Colors.orange, size: 40),
                  title: Text(title,
                      style: TextStyle(
                          color: themeProvider.textColor, fontWeight: FontWeight.bold)),
                  subtitle: Text(caption, style: TextStyle(color: themeProvider.textColor)),
                  trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.textColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseVideoPlayer(
                          courseId: courseId,
                          startIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
