import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:thinkflow/thinkflow/administration/payment.dart';
import 'package:thinkflow/thinkflow/Mentor/courseuplode.dart';
import 'package:thinkflow/thinkflow/Mentor/registration.dart';
import 'package:thinkflow/thinkflow/mentor/course.dart';

class MentorProfile extends StatefulWidget {
  final String mentorId;
  const MentorProfile({super.key, required this.mentorId});

  @override
  State<MentorProfile> createState() => _MentorProfileState();
}

class _MentorProfileState extends State<MentorProfile> {
  String mentorName = "Loading...";
  String profileImg = "";
  String profession = "";
  int followersCount = 0;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isMeetingLive = false;
  String? meetingChannelName;
  String meetingStatus = "No active meeting";

  @override
  void initState() {
    super.initState();
    _fetchMentorDetails();
    // _setupMeetingListener();
  }

  // void _setupMeetingListener() {
  //   FirebaseFirestore.instance
  //       .collection('mentors')
  //       .doc(widget.mentorId)
  //       .snapshots()
  //       .listen((snapshot) {
  //     if (snapshot.exists) {
  //       final data = snapshot.data() as Map<String, dynamic>;
  //       setState(() {
  //         isMeetingLive = data['isLive'] ?? false;
  //         meetingChannelName = data['channelName'];
  //         meetingStatus = isMeetingLive 
  //             ? "Meeting is live!" 
  //             : "No active meeting";
  //       });
  //     }
  //   });
  // }

  // Future<void> toggleMeeting() async {
  //   final docRef = FirebaseFirestore.instance.collection('mentors').doc(widget.mentorId);

  //   if (!isMeetingLive) {
  //     // Generate a unique channel name
  //     final channelName = '${widget.mentorId}_${DateTime.now().millisecondsSinceEpoch}';
      
  //     // Start meeting
  //     await docRef.update({
  //       'isLive': true,
  //       'channelName': channelName,
  //       'meetingStartTime': FieldValue.serverTimestamp(),
  //     });
      
  //     // Navigate to video call screen
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => VideoCallScreen(channelName: channelName, isMentor: false),
  //       ),
  //     );
  //   } else {
  //     // End meeting
  //     await docRef.update({
  //       'isLive': false,
  //       'channelName': '',
  //       'meetingEndTime': FieldValue.serverTimestamp(),
  //     });
  //   }
  // }

  void _fetchMentorDetails() async {
    DocumentSnapshot mentorDoc = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(widget.mentorId)
        .get();

    if (mentorDoc.exists) {
      var mentorData = mentorDoc.data() as Map<String, dynamic>;
      setState(() {
        mentorName = mentorData['name'] ?? 'Unknown';
        profileImg = mentorData['profileimg'] ?? '';
        profession = mentorData['profession'] ?? 'N/A';
        followersCount = (mentorData['followers'] as List?)?.length ?? 0;
        isMeetingLive = mentorData['isLive'] ?? false;
        meetingChannelName = mentorData['channelName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isMentor = widget.mentorId == currentUserId;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        actions: isMentor
            ? [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: themeProvider.textColor),
                  onSelected: (value) {
                    if (value == 'add_course') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CourseUpload()),
                      );
                    } else if (value == 'add_poster') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBankAccountPage(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'add_course', child: Text('Add Course')),
                    const PopupMenuItem(
                        value: 'add_poster', child: Text('Add Poster')),
                       
                  ],
                )
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImg.isNotEmpty
                        ? NetworkImage(profileImg)
                        : null,
                    child: profileImg.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: themeProvider.textColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(mentorName,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor)),
                  Text(profession,
                      style: TextStyle(
                          color: themeProvider.textColor.withOpacity(0.7))),
                  if (isMentor) ...[
                    SizedBox(width: 5),
                    IconButton(
                      icon: Icon(Icons.edit, color: themeProvider.textColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MentorLoginPage()),
                        ).then((_) => _fetchMentorDetails());
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Followers Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group,
                          color: themeProvider.textColor, size: 20),
                      const SizedBox(width: 5),
                      Text("$followersCount Followers",
                          style: TextStyle(
                              fontSize: 16, color: themeProvider.textColor)),
                    ],
                  ),
                  // if (isMentor) ...[
                  //   const SizedBox(height: 15),
                  //   Column(
                  //     children: [
                  //       Text(
                  //         meetingStatus,
                  //         style: TextStyle(
                  //           color: isMeetingLive ? Colors.green : Colors.grey,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       ElevatedButton.icon(
                  //         onPressed: toggleMeeting,
                  //         icon: Icon(
                  //           isMeetingLive ? Icons.stop : Icons.video_call,
                  //           color: Colors.white,
                  //         ),
                  //         label: Text(
                  //           isMeetingLive ? "End Meeting" : "Start Meeting",
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: isMeetingLive 
                  //               ? Colors.red 
                  //               : Colors.green,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //         ),
                  //       ),
                  //       if (isMeetingLive) ...[
                  //         const SizedBox(height: 10),
                  //         ElevatedButton(
                  //           onPressed: () {
                  //             if (meetingChannelName != null) {
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) => 
                  //                     VideoCallScreen(channelName: meetingChannelName!, isMentor: false,),
                  //                 ),
                  //               );
                  //             }
                  //           },
                  //           child: Text("Join Meeting",
                  //               style: TextStyle(color: Colors.white)),
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: Colors.blue,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ],
                  //   ),
                  // ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Courses Section
            Expanded(child: _buildCoursesList(isMentor, themeProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(bool isMentor, ThemeProvider themeProvider) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where("uid", isEqualTo: widget.mentorId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            'No courses available',
            style: TextStyle(color: themeProvider.textColor),
          ));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final course = snapshot.data!.docs[index];
            return _buildCourseItem(course, isMentor, themeProvider);
          },
        );
      },
    );
  }

  Widget _buildCourseItem(QueryDocumentSnapshot course, bool isMentor,
      ThemeProvider themeProvider) {
    Map<String, dynamic> courseData = course.data() as Map<String, dynamic>;
    String title = courseData['name'] ?? 'Untitled Course';
    String category = courseData['category'] ?? 'N/A';
    String price = courseData['price']?.toString() ?? '0';
    String ImageUrl = courseData['imageUrl'] ?? '';
    String courseId = course.id;

    return Card(
      color: themeProvider.textColor.withOpacity(0.1),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: ImageUrl.isEmpty ? Colors.grey[300] : null,
            image: ImageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(ImageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: themeProvider.textColor)),
        subtitle: Text("Category: $category",
            style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))),
        trailing: isMentor
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CourseUpload(courseId: courseId)),
                    );
                  } else if (value == 'delete') {
                    _deleteCourse(courseId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              )
            : null,
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
  }

  void _deleteCourse(String courseId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course deleted successfully")),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Course"),
            content: const Text("Are you sure you want to delete this course?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }
}