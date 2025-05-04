import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Mentor/mentorview.dart';
import 'package:thinkflow/ThinkFlow/Mentor/mentprof.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/administration/sendmoney.dart';
import 'package:thinkflow/ThinkFlow/videoplayer.dart';
import 'package:thinkflow/User/review.dart';
import 'package:thinkflow/ThinkFlow/videopage.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  CourseDetailPage({super.key, required this.courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  int likesCount = 0;
  bool isLiked = false;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initializeLikeStatus();
  }

  /// Initialize Follower Count and Check if User is Following
  void _initializeLikeStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('courseId', isEqualTo: widget.courseId)
        .get();

    if (reviewSnapshot.docs.isNotEmpty) {
      int totalLikes = 0;
      bool userLiked = false;
      for (var doc in reviewSnapshot.docs) {
        var reviewData = doc.data() as Map<String, dynamic>;
        List<dynamic> likes = List<dynamic>.from(reviewData['likes'] ?? []);
        totalLikes += likes.length;
        if (likes.contains(userId)) {
          userLiked = true; // User has liked at least one review
        }
      }

      setState(() {
        likesCount = totalLikes;
        isLiked = userLiked;
      });
    }
  }

  void _toggleLike(
      String reviewId, bool isLiked, List<dynamic> likedUsers) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reviewRef =
        FirebaseFirestore.instance.collection('reviews').doc(reviewId);

    if (isLiked) {
      // Unfollow: Remove user from followers array
      await reviewRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      // Follow: Add user to followers array
      await reviewRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  /// Toggle Follow/Unfollow and update Firestore

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("courses")
              .doc(widget.courseId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var course = snapshot.data!;
            String mentorId = course['uid'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("mentors")
                  .doc(mentorId)
                  .get(),
              builder: (context, mentorSnapshot) {
                if (mentorSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (mentorSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var mentor = mentorSnapshot.data!;
                String? imageUrl = mentor['profileimg'];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: course['imageUrl'] != null &&
                                  course['imageUrl'].isNotEmpty
                              ? null
                              : (themeProvider.isDarkMode
                                  ? Colors.grey[200]
                                  : Colors.grey[900]),
                          image: course['imageUrl'] != null &&
                                  course['imageUrl'].isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(course['imageUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(course['category'],
                                    style: TextStyle(
                                        color: Colors.orange, fontSize: 14)),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseVideosPage(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.play_circle_fill),
                                  label: Text("Watch Preview"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              course['name'],
                              style: TextStyle(
                                  color: themeProvider.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.class_,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "21 Class",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("35 Hours",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${course['offerPrice']} ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ),
                                _buildBuyCourseButton(
                                    widget.courseId, mentorId, themeProvider)
                              ],
                            ),
                            SizedBox(height: 16),

                            GestureDetector(
                              onTap: () {
                                if (currentUserId == mentorId) {
                                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MentorProfile(mentorId: mentorId),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MentorScreen(mentorId: mentorId),
                    ),
                  );
                                }
                                
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.brown[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.black,
                                        backgroundImage: imageUrl != null &&
                                                imageUrl.isNotEmpty
                                            ? NetworkImage(imageUrl)
                                            : null),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(mentor['name'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text(mentor['profession'],
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.chat_bubble_outline),
                                    onPressed:(){ startChat(context, mentorId);},
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Reviews Section
                            Text("Reviews",
                                style: TextStyle(
                                    color: themeProvider.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReviewPage(
                                              courseId: widget.courseId,
                                            )));
                              },
                              child: Text("write a review...",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 14)),
                            ),
                            SizedBox(height: 16),

                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('reviews')
                                    .where('courseId',
                                        isEqualTo: widget.courseId)
                                    // .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                        child: Text("No reviews yet"));
                                  }
                                  var reviews = snapshot.data!.docs;
                                  return Column(
                                    children: reviews.map<Widget>((review) {
                                      var data =
                                          review.data() as Map<String, dynamic>;
                                      String userId = data.containsKey('userId')
                                          ? data['userId']
                                          : '';
                                      String name = data.containsKey('userName')
                                          ? data['userName']
                                          : 'Anonymous';
                                      String userProfile =
                                          data.containsKey('userProfile')
                                              ? data['userProfile']
                                              : '';
                                      String reviewText =
                                          data.containsKey('review')
                                              ? data['review']
                                              : '';
                                      double rating = data.containsKey('rating')
                                          ? (data['rating'] as num).toDouble()
                                          : 0.0;

                                      List<dynamic> likedUsers = [];
                                      if (data['likes'] is List) {
                                        likedUsers =
                                            List<dynamic>.from(data['likes']);
                                      }
                                      int likes = likedUsers.length;
                                      String time = timeAgo(
                                          data.containsKey('timestamp')
                                              ? data['timestamp']
                                              : null);

                                      return _buildReviewItem(
                                          userProfile,
                                          name,
                                          reviewText,
                                          rating,
                                          likes,
                                          time,
                                          review.id,
                                          userId,
                                          likedUsers,
                                          themeProvider);
                                    }).toList(),
                                  );
                                })

                            // Review List
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }

  Widget _buildReviewItem(
    String? imageUrl,
    String name,
    String review,
    double rating,
    int likes,
    String time,
    String reviewId,
    String reviewpostId,
    List<dynamic> likedUsers,
    ThemeProvider themeProvider,
  ) {
    User? user = FirebaseAuth.instance.currentUser;
    bool isLiked = likedUsers.contains(user?.uid);
    bool isCurrentUser = user?.uid == reviewpostId;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            backgroundColor: Colors.brown,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          Text(rating.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(review, style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                        onPressed: () =>
                            _toggleLike(reviewId, isLiked, likedUsers),
                        icon: Icon(Icons.favorite,
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 16)),
                    SizedBox(width: 4),
                    Text(
                      "$likes",
                      style: TextStyle(color: themeProvider.textColor),
                    ),
                    SizedBox(width: 16),
                    Text(time, style: TextStyle(color: Colors.grey)),
                    if (isCurrentUser)
                      IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('reviews')
                              .doc(reviewId)
                              .delete();
                        },
                        icon: Icon(Icons.delete, color: Colors.red, size: 16),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyCourseButton(
      String courseId, String mentorId, ThemeProvider themeProvider) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange, // Buy button color
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SendMoneyPage(
                        courseId: courseId,
                        mentorId: mentorId,
                      )));
        },
        child: Text(
          "Buy Course",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
