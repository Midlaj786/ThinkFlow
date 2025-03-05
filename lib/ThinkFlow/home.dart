import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkflow/ThinkFlow/course.dart';
import 'package:thinkflow/ThinkFlow/courseuplode.dart';
import 'package:thinkflow/ThinkFlow/llll.dart';
import 'package:thinkflow/ThinkFlow/mentor.dart';
import 'package:thinkflow/ThinkFlow/mentprof.dart';
// import 'package:thinkflow/ThinkFlow/all_courses.dart'; // Add a page for displaying all courses

class HomePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              SizedBox(height: 16),
              _buildBanner(),
              SizedBox(height: 16),
              _buildSectionTitle('Popular Courses', context),
              _buildCategoryChips(),
              SizedBox(height: 16),
              _buildCoursesList(),
              SizedBox(height: 16),
              _buildSectionTitle('Top Mentors', context),
              _buildMentorsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            FirebaseFirestore.instance
                .collection('users')
                .get()
                .then((snapshot) {
              if (snapshot.docs.isEmpty) {
                print('No users found!');
              } else {
                for (var doc in snapshot.docs) {
                  print(doc.data());
                }
              }
            });

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => AllCoursesPage()), // Navigate to all courses page
            // );
          },
          child: Text(
            'SEE ALL',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            title: Text("Become a Mentor"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MentorLoginPage()),
              );
            },
          ),
          ListTile(
            title: Text("Courses"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Courseuplode()),
              );
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Colors.black, radius: 16),
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, color: Colors.orange, size: 30),
          SizedBox(width: 5),
          Text(
            "ThinkFlow",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 196, 18, 18),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for ...',
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Row(
      children: [
        Chip(label: Text('All')),
        SizedBox(width: 8),
        Chip(
            label:
                Text('Graphic Design', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green),
        SizedBox(width: 8),
        Chip(label: Text('Web Development')),
      ],
    );
  }

  Widget _buildCoursesList() {
    return Container(
      height: 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var courses = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];
              return FutureBuilder(
                future: _calculateAverageRating(course.id),
                builder: (context, ratingSnapshot) {
                  double avgRating = ratingSnapshot.data ??
                      double.tryParse(course['rating'].toString()) ??
                      0.0;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(
                            courseId: course.id,
                          ),
                        ),
                      );
                    },
                    child: _buildCourseCard(
                      course['category'] ?? 'Unknown',
                      course['name'] ?? 'No Title',
                      double.tryParse(course['offerPrice'].toString()) ?? 0.0,
                      double.tryParse(course['price'].toString()) ?? 0.0,
                      avgRating,
                      course['imageUrl'] ?? '',
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<double> _calculateAverageRating(String courseId) async {
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get();
    double savedRating = double.tryParse(courseSnapshot['rating'].toString()) ??
        0.0; // Get saved rating

    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('courseId', isEqualTo: courseId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return savedRating;
    ; // No reviews, return 0

    double totalRating = 0;
    int count = 0;

    for (var doc in reviewsSnapshot.docs) {
      var reviewData = doc.data() as Map<String, dynamic>;
      if (reviewData.containsKey('rating') && reviewData['rating'] is num) {
        totalRating += (reviewData['rating'] as num).toDouble();
        count++;
      }
    }

    double avgRating = count > 0 ? totalRating / count : 0.0;
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
      'rating': avgRating,
    });

    return avgRating; // ✅ Return the updated rating to UI
  }
}

Widget _buildCourseCard(String category, String name, double offerPrice,
    double price, double rating, String? imageUrl) {
  return Container(
    width: 180,
    margin: EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.black,
                    );
                  },
                )
              : Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.black,
                ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: TextStyle(color: Colors.orange, fontSize: 12)),
              SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\₹${offerPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '\₹${price.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildMentorsList() {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  return SizedBox(
    height: 300, // Adjust height as needed
    child: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No mentors available'));
        }
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust number of items per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var mentor = snapshot.data!.docs[index];
            String name = mentor['name'] ?? 'Unknown';
            String? imageUrl = mentor['profileimg'];
            String mentorId = mentor.id;

            return GestureDetector(
              onTap: () {
                if (currentUserId == mentorId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => mentorProfile(),
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40, // Adjust size
                    backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
