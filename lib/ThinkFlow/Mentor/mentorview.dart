import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/administration/onlinecall.dart';
import 'package:thinkflow/ThinkFlow/course.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class MentorScreen extends StatefulWidget {
  final String mentorId;
   MentorScreen({super.key, required this.mentorId});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  int followersCount = 0;
  bool isFollowing = false;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _initializeFollowerStatus();
  }

  /// Initialize Follower Count and Check if User is Following
  void _initializeFollowerStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot mentorSnapshot = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(widget.mentorId)
        .get();

    if (mentorSnapshot.exists) {
      var mentorData = mentorSnapshot.data() as Map<String, dynamic>?;

      if (mentorData != null) {
        List<dynamic> followers = mentorData['followers'] ?? [];

        setState(() {
          followersCount = followers.length;
          isFollowing =
              followers.contains(userId); // Check if user already follows
        });
      }
    }
  }

  /// Toggle Follow/Unfollow and update Firestore
  void _toggleFollow() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference mentorRef =
        FirebaseFirestore.instance.collection('mentors').doc(widget.mentorId);

    if (isFollowing) {
      // Unfollow: Remove user from followers array
      await mentorRef.update({
        'followers': FieldValue.arrayRemove([userId])
      });
      setState(() {
        isFollowing = false;
        followersCount -= 1;
      });
    } else {
      // Follow: Add user to followers array
      await mentorRef.update({
        'followers': FieldValue.arrayUnion([userId])
      });
      setState(() {
        isFollowing = true;
        followersCount += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
        length: 2,
        child: Scaffold(backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon:  Icon(Icons.arrow_back, color:themeProvider.textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('mentors')
                  .doc(widget.mentorId)
                  .get(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return Center(child: CircularProgressIndicator());
                // }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return  Center(child: CircularProgressIndicator());
                }
                var mentor = snapshot.data!;
                String name = mentor['name'] ?? 'Unknown';
                String profileImg = mentor['profileimg'] ?? '';
                String profession = mentor['profession'] ?? 'N/A';
                return Column(
                  children: [
                    CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImg.isNotEmpty
                            ? NetworkImage(profileImg)
                            :  AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                        backgroundColor: Colors.black),
                     SizedBox(height: 8),
                    Text(name,
                        style:  TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold,color: themeProvider.textColor)),
                    Text(profession, style:  TextStyle(color: Colors.grey)),
                     SizedBox(height: 12),
                    _buildStatsRow(themeProvider),
                     SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFollowButton(),
                         SizedBox(width: 8),
                        _buildButton('Message', Colors.grey),
                      ],
                    ),
                     SizedBox(height: 16),
                     TabBar(
                      labelColor: themeProvider.textColor,
                      indicatorColor: Colors.blue,
                      tabs: [
                        Tab(text: 'Courses'),
                        Tab(text: 'Meetings'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildCoursesTab(),
                          _buildCoursesTab(),
                          // _buildJoinMeetingButton(),
                          // _buildRatingsTab(),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ));
  }

  Widget _buildStatsRow(ThemeProvider themeProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('uid', isEqualTo: widget.mentorId)
          .snapshots(),
      builder: (context, snapshot) {
        int courseCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoColumn('$courseCount', 'Courses',themeProvider),
            _buildInfoColumn('$followersCount', 'Followers',themeProvider),
          ],
        );
      },
    );
  }

  Widget _buildFollowButton() {
    return SizedBox(
      height: 50,
      width: 150,
      child: ElevatedButton(
        onPressed: _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.grey : Colors.blue,
          padding:  EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(8),
          // ),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label,ThemeProvider themeProvider) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(value,
              style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:themeProvider.textColor )),
          Text(label, style:  TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return SizedBox(
      height: 50,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          startChat(context, widget.mentorId);
        },
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(text,
            style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCoursesTab() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where("uid", isEqualTo: widget.mentorId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return  Center(child: Text('No courses available'));
          }
          return ListView.builder(
            padding:  EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final course = snapshot.data!.docs[index];

              return _buildCourseItem(course);
            },
          );
        });
  }
// Widget _buildJoinMeetingButton() {
//   return StreamBuilder<DocumentSnapshot>(
//     stream: FirebaseFirestore.instance
//         .collection('mentors')
//         .doc(widget.mentorId)
//         .snapshots(),
//     builder: (context, snapshot) {
//       if (snapshot.hasError) {
//         return Text('Something went wrong');
//       }

//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return SizedBox(); // Or a small loading indicator if you prefer
//       }

//       if (!snapshot.hasData || !snapshot.data!.exists) {
//         return SizedBox();
//       }

//       final data = snapshot.data!.data() as Map<String, dynamic>?;
//       final isLive = data?['isLive'] ?? false;
//       final channelName = data?['channelName'] ?? '';

//       if (isLive && channelName.isNotEmpty) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => VideoCallScreen(channelName: channelName, isMentor: true,),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.video_call),
//               label: Text('Join Live Meeting', style: TextStyle(fontSize: 16)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green, // Or your preferred color
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }

//       return SizedBox(); // No button if not live or no channel name
//     },
//   );
// }


  Widget _buildCourseItem(QueryDocumentSnapshot course) {
    Map<String, dynamic> courseData = course.data() as Map<String, dynamic>;
    String title = courseData['name'] ?? 'Untitled Course';
    String category = courseData['category'] ?? 'N/A';
    String price = courseData['price']?.toString() ?? '0';
    String oldPrice = courseData['offerPrice']?.toString() ?? '0';
    String courseId = course.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(courseId: courseId),
          ),
        );
      },
      child: Container(
        margin:  EdgeInsets.symmetric(vertical: 10),
        padding:  EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(10)),
            ),
             SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                      style:  TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold)),
                   SizedBox(height: 5),
                  Text(title,
                      style:
                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   SizedBox(height: 5),
                  Row(
                    children: [
                      Text('\$$price',
                          style:  TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                       SizedBox(width: 5),
                      Text('\$$oldPrice',
                          style:  TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildRatingsTab() {
  //   return ListView.builder(
  //     padding:  EdgeInsets.all(16),
  //     itemCount: ratings.length,
  //     itemBuilder: (context, index) {
  //       final review = ratings[index];
  //       return _buildRatingItem(review);
  //     },
  //   );
  // }

  // Widget _buildRatingItem(Map<String, dynamic> review) {
  //   return Card(
  //     child: ListTile(
  //       leading: CircleAvatar(backgroundColor: Colors.black),
  //       title: Text(review['name']!),
  //       subtitle: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('The Course is Very Good.'),
  //           Row(
  //             children: [
  //               Icon(Icons.star, color: Colors.orange, size: 16),
  //               Text('${review['rating']}'),
  //               SizedBox(width: 8),
  //               Icon(Icons.favorite, color: Colors.red, size: 16),
  //               Text('${review['likes']}'),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
