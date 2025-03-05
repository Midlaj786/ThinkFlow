import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thinkflow/ThinkFlow/review.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  CourseDetailPage({required this.courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  int likesCount = 0;
  bool isLiked = false;

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
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
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
                        color: Colors.black,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course['category'],
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 14)),
                            SizedBox(height: 4),
                            Text(
                              course['name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.class_,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("21 Class"),
                                SizedBox(width: 16),
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("35 Hours"),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "\₹${course['offerPrice']} ",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            SizedBox(height: 16),

                            Container(
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
                                  Icon(Icons.chat_bubble_outline,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Reviews Section
                            Text("Reviews",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
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
                                      var data = review.data();
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
                                        likedUsers,
                                      );
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
    List<dynamic> likedUsers,
  ) {
    User? user = FirebaseAuth.instance.currentUser;
    bool isLiked = likedUsers.contains(user?.uid);
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
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text("$likes"),
                    SizedBox(width: 16),
                    Text(time, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
