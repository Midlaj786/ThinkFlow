import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Mentor/mentorview.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:thinkflow/thinkflow/mentor/course.dart';

class SavedCoursesPage extends StatefulWidget {
  const SavedCoursesPage({super.key});

  @override
  State<SavedCoursesPage> createState() => _SavedCoursesPageState();
}

class _SavedCoursesPageState extends State<SavedCoursesPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Saved Courses')),
        body: Center(child: Text('Please log in to view saved courses.')),
      );
    }

    final savedCoursesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedCourses');

    final followedMentorsQuery = FirebaseFirestore.instance
        .collection('mentors')
        .where('followers', arrayContains: userId);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text('Saved Courses', style: TextStyle(color: themeProvider.textColor)),
        backgroundColor: themeProvider.backgroundColor,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top half for saved courses
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: savedCoursesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No saved courses.',
                      style: TextStyle(color: themeProvider.textColor),
                    ),
                  );
                }

                final savedDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: savedDocs.length,
                  itemBuilder: (context, index) {
                    final courseId = savedDocs[index].id;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('courses')
                          .doc(courseId)
                          .get(),
                      builder: (context, courseSnap) {
                        if (!courseSnap.hasData || !courseSnap.data!.exists) {
                          return SizedBox();
                        }

                        final course = courseSnap.data!;
                        final imageUrl = course['imageUrl'] ?? '';

                        return Card(
                          color: themeProvider.backgroundColor,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : CircleAvatar(child: Icon(Icons.book)),
                            title: Text(
                              course['name'] ?? 'No Name',
                              style: TextStyle(color: themeProvider.textColor),
                            ),
                            subtitle: Text(
                              course['category'] ?? '',
                              style: TextStyle(color: themeProvider.textColor.withOpacity(0.6)),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.textColor),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailPage(courseId: courseId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Divider line
          // Divider(height: 1, color: Colors.grey),

          // Bottom half for mentors
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Followed Mentors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: followedMentorsQuery.snapshots(),
                    builder: (context, mentorSnapshot) {
                      if (mentorSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!mentorSnapshot.hasData || mentorSnapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No followed mentors.',
                            style: TextStyle(color: themeProvider.textColor),
                          ),
                        );
                      }

                      final mentors = mentorSnapshot.data!.docs;

                      return GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        itemCount: mentors.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final mentorData = mentors[index].data() as Map<String, dynamic>;
                          final hasImage = mentorData['profileimg'] != null &&
                              mentorData['profileimg'].toString().isNotEmpty;
                          final mentorId = mentors[index].id;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MentorScreen(mentorId: mentorId),
                                ),
                              );
                            },
                            child: Card(
                              color: themeProvider.backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          hasImage ? NetworkImage(mentorData['profileimg']) : null,
                                      child: !hasImage
                                          ? Icon(Icons.person, color: themeProvider.textColor)
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      mentorData['name'] ?? 'Mentor',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textColor,
                                      ),
                                    ),
                                    Text(
                                      mentorData['profession'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.textColor,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
